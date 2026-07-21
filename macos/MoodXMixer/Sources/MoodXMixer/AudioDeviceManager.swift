import AudioToolbox
import CoreAudio
import Foundation

struct AudioDevice: Identifiable, Hashable {
    let id: AudioDeviceID
    let uid: String
    let name: String
    let inputChannels: UInt32
    let outputChannels: UInt32

    var isBlackHole: Bool {
        name.localizedCaseInsensitiveContains("BlackHole")
    }
}

enum CoreAudioFailure: LocalizedError {
    case status(OSStatus, String)
    case missingDevice(String)

    var errorDescription: String? {
        switch self {
        case let .status(status, operation):
            return "\(operation) failed (Core Audio status \(status))."
        case let .missingDevice(name):
            return "Required audio device not found: \(name)."
        }
    }
}

enum AudioDeviceManager {
    static func devices() throws -> [AudioDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        try check(
            AudioObjectGetPropertyDataSize(
                AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size
            ),
            "Reading audio-device list size"
        )

        let count = Int(size) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        try check(
            AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &ids
            ),
            "Reading audio-device list"
        )

        return try ids.compactMap { id in
            let name = try stringProperty(id, kAudioObjectPropertyName)
            let uid = try stringProperty(id, kAudioDevicePropertyDeviceUID)
            let inputChannels = try channelCount(id, scope: kAudioDevicePropertyScopeInput)
            let outputChannels = try channelCount(id, scope: kAudioDevicePropertyScopeOutput)
            guard inputChannels > 0 || outputChannels > 0 else { return nil }
            return AudioDevice(
                id: id,
                uid: uid,
                name: name,
                inputChannels: inputChannels,
                outputChannels: outputChannels
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func createPrivateAggregate(input: AudioDevice, output: AudioDevice) throws -> AudioDeviceID {
        let aggregateUID = "com.moodx.mixer.aggregate.\(UUID().uuidString)"
        let subdevices: [[String: Any]] = [
            [
                kAudioSubDeviceUIDKey as String: input.uid,
                kAudioSubDeviceDriftCompensationKey as String: 1
            ],
            [kAudioSubDeviceUIDKey as String: output.uid]
        ]
        let description: [String: Any] = [
            kAudioAggregateDeviceNameKey as String: "MoodX Private Mix",
            kAudioAggregateDeviceUIDKey as String: aggregateUID,
            kAudioAggregateDeviceSubDeviceListKey as String: subdevices,
            kAudioAggregateDeviceMasterSubDeviceKey as String: output.uid,
            kAudioAggregateDeviceIsPrivateKey as String: 1,
            kAudioAggregateDeviceIsStackedKey as String: 0
        ]

        var aggregateID = AudioDeviceID(kAudioObjectUnknown)
        try check(
            AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateID),
            "Creating private MoodX aggregate device"
        )
        return aggregateID
    }

    static func destroyAggregate(_ id: AudioDeviceID) {
        guard id != kAudioObjectUnknown else { return }
        AudioHardwareDestroyAggregateDevice(id)
    }

    static func setCurrentDevice(_ device: AudioDeviceID, on audioUnit: AudioUnit) throws {
        var mutableDevice = device
        try check(
            AudioUnitSetProperty(
                audioUnit,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global,
                0,
                &mutableDevice,
                UInt32(MemoryLayout<AudioDeviceID>.size)
            ),
            "Connecting audio engine to aggregate device"
        )
    }

    static func mapFirstInputChannel(on audioUnit: AudioUnit) throws {
        var channelMap: [Int32] = [0]
        try channelMap.withUnsafeMutableBytes { bytes in
            try check(
                AudioUnitSetProperty(
                    audioUnit,
                    kAudioOutputUnitProperty_ChannelMap,
                    kAudioUnitScope_Output,
                    1,
                    bytes.baseAddress,
                    UInt32(bytes.count)
                ),
                "Mapping selected microphone channel"
            )
        }
    }

    private static func stringProperty(
        _ object: AudioObjectID,
        _ selector: AudioObjectPropertySelector
    ) throws -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: CFString = "" as CFString
        var size = UInt32(MemoryLayout<CFString>.size)
        try withUnsafeMutablePointer(to: &value) { pointer in
            try check(
                AudioObjectGetPropertyData(object, &address, 0, nil, &size, pointer),
                "Reading audio-device property"
            )
        }
        return value as String
    }

    private static func channelCount(
        _ device: AudioDeviceID,
        scope: AudioObjectPropertyScope
    ) throws -> UInt32 {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        try check(
            AudioObjectGetPropertyDataSize(device, &address, 0, nil, &size),
            "Reading audio stream configuration size"
        )
        guard size > 0 else { return 0 }

        let raw = UnsafeMutableRawPointer.allocate(
            byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer { raw.deallocate() }
        let list = raw.bindMemory(to: AudioBufferList.self, capacity: 1)
        try check(
            AudioObjectGetPropertyData(device, &address, 0, nil, &size, list),
            "Reading audio stream configuration"
        )
        return UnsafeMutableAudioBufferListPointer(list).reduce(0) {
            $0 + $1.mNumberChannels
        }
    }

    private static func check(_ status: OSStatus, _ operation: String) throws {
        guard status == noErr else { throw CoreAudioFailure.status(status, operation) }
    }
}

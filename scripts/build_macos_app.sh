#!/bin/zsh
set -euo pipefail

project_root="${0:A:h:h}"
package_root="$project_root/macos/MoodXMixer"
app_root="$project_root/dist/MoodX Mixer.app"
contents_root="$app_root/Contents"
stt_source_root="$project_root/.cache/moodx-stt/whisper.cpp"
stt_resource_root="$contents_root/Resources/LocalSTT"

swift build --package-path "$package_root" -c release

mkdir -p "$contents_root/MacOS" "$contents_root/Resources"
cp "$package_root/.build/release/MoodXMixer" "$contents_root/MacOS/MoodXMixer"
cp "$package_root/Resources/Info.plist" "$contents_root/Info.plist"

stt_binary="$stt_source_root/build-static/bin/whisper-cli"
stt_model="$stt_source_root/models/ggml-small.bin"
stt_vad="$stt_source_root/models/ggml-silero-v6.2.0.bin"
if [[ -x "$stt_binary" && -f "$stt_model" ]]; then
    mkdir -p "$stt_resource_root"
    cp "$stt_binary" "$stt_resource_root/whisper-cli"
    cp "$stt_model" "$stt_resource_root/ggml-small.bin"
    if [[ -f "$stt_vad" ]]; then
        cp "$stt_vad" "$stt_resource_root/ggml-silero-v6.2.0.bin"
    fi
    cp "$stt_source_root/LICENSE" "$stt_resource_root/whisper.cpp-LICENSE.txt"
    codesign --force --sign - "$stt_resource_root/whisper-cli"
    echo "Bundled local STT runtime and multilingual small model."
else
    echo "Local STT runtime not bundled; run the documented setup and rebuild."
fi

codesign --force --deep --sign - "$app_root"

echo "Built: $app_root"

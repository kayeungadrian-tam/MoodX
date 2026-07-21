"use strict";

const ui = {
  connect: document.querySelector("#connect-button"),
  panic: document.querySelector("#panic-button"),
  state: document.querySelector("#connection-state"),
  input: document.querySelector("#input-device"),
  output: document.querySelector("#output-device"),
  monitor: document.querySelector("#monitor-device"),
  routingSummary: document.querySelector("#routing-summary"),
  notice: document.querySelector("#notice"),
  meter: document.querySelector("#meter-fill"),
  nowPlaying: document.querySelector("#now-playing"),
  padGrid: document.querySelector("#pad-grid"),
  teamsAudio: document.querySelector("#teams-output"),
  monitorAudio: document.querySelector("#monitor-output"),
  micGain: document.querySelector("#mic-gain"),
  sfxGain: document.querySelector("#sfx-gain"),
  monitorGain: document.querySelector("#monitor-gain"),
  masterGain: document.querySelector("#master-gain"),
  micValue: document.querySelector("#mic-value"),
  sfxValue: document.querySelector("#sfx-value"),
  monitorValue: document.querySelector("#monitor-value"),
  masterValue: document.querySelector("#master-value"),
  micMute: document.querySelector("#mic-mute"),
  monitorMute: document.querySelector("#monitor-mute"),
  masterMute: document.querySelector("#master-mute"),
  duck: document.querySelector("#duck-toggle"),
};

const state = {
  context: null,
  stream: null,
  micSource: null,
  mic: null,
  sfx: null,
  master: null,
  analyser: null,
  monitor: null,
  teamsDestination: null,
  monitorDestination: null,
  activeNodes: new Set(),
  connected: false,
  micMuted: false,
  monitorMuted: false,
  masterMuted: false,
  duckEnabled: true,
  duckTimers: new Set(),
  meterFrame: null,
};

const labels = {
  tada: "Big Win",
  airhorn: "Air Horn",
  applause: "Applause",
  drumroll: "Drum Roll",
  rimshot: "Rimshot",
  chime: "Think Time",
  buzzer: "Buzzer",
  timeup: "Time",
  warp: "Warp Out",
};

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const gainValue = (input) => Number(input.value) / 100;

function setNotice(message, isError = false) {
  ui.notice.textContent = message;
  ui.notice.style.color = isError ? "#ff7d87" : "";
}

function setConnection(status, label) {
  ui.state.dataset.state = status;
  ui.state.querySelector("strong").textContent = label;
}

function setButtonState(button, pressed) {
  button.setAttribute("aria-pressed", String(pressed));
  button.classList.toggle("is-active", pressed);
}

function setPadsEnabled(enabled) {
  ui.padGrid.querySelectorAll("button").forEach((button) => {
    button.disabled = !enabled;
  });
}

function makeGain(value) {
  const node = state.context.createGain();
  node.gain.value = value;
  return node;
}

function createAudioGraph() {
  state.mic = makeGain(gainValue(ui.micGain));
  state.sfx = makeGain(gainValue(ui.sfxGain));
  state.master = makeGain(gainValue(ui.masterGain));
  state.monitor = makeGain(gainValue(ui.monitorGain));
  state.analyser = state.context.createAnalyser();
  state.analyser.fftSize = 256;
  state.analyser.smoothingTimeConstant = 0.72;
  state.teamsDestination = state.context.createMediaStreamDestination();
  state.monitorDestination = state.context.createMediaStreamDestination();

  state.mic.connect(state.master);
  state.sfx.connect(state.master);
  state.master.connect(state.analyser);
  state.analyser.connect(state.teamsDestination);
  state.sfx.connect(state.monitor);
  state.monitor.connect(state.monitorDestination);

  ui.teamsAudio.srcObject = state.teamsDestination.stream;
  ui.monitorAudio.srcObject = state.monitorDestination.stream;
}

async function requestMicrophone(deviceId = "") {
  if (state.stream) {
    state.stream.getTracks().forEach((track) => track.stop());
  }
  if (state.micSource) {
    state.micSource.disconnect();
  }

  const audio = {
    echoCancellation: false,
    noiseSuppression: false,
    autoGainControl: false,
    channelCount: 1,
  };
  if (deviceId) audio.deviceId = { exact: deviceId };

  state.stream = await navigator.mediaDevices.getUserMedia({ audio, video: false });
  state.micSource = state.context.createMediaStreamSource(state.stream);
  state.micSource.connect(state.mic);
}

function fillSelect(select, devices, placeholder, includeOff = false) {
  const current = select.value;
  select.replaceChildren();
  if (includeOff) {
    const off = new Option("Monitor off", "");
    select.add(off);
  }
  devices.forEach((device, index) => {
    select.add(new Option(device.label || `${placeholder} ${index + 1}`, device.deviceId));
  });
  if ([...select.options].some((option) => option.value === current)) select.value = current;
}

async function refreshDevices() {
  const devices = await navigator.mediaDevices.enumerateDevices();
  const inputs = devices.filter((device) => device.kind === "audioinput");
  const outputs = devices.filter((device) => device.kind === "audiooutput");
  fillSelect(ui.input, inputs, "Microphone");
  fillSelect(ui.output, outputs, "Output");
  fillSelect(ui.monitor, outputs, "Monitor", true);

  const trackDevice = state.stream?.getAudioTracks()[0]?.getSettings().deviceId;
  if (trackDevice && inputs.some((device) => device.deviceId === trackDevice)) {
    ui.input.value = trackDevice;
  }

  const savedOutput = localStorage.getItem("moodx-output");
  const blackHole = outputs.find((device) => /blackhole/i.test(device.label));
  if (savedOutput && outputs.some((device) => device.deviceId === savedOutput)) {
    ui.output.value = savedOutput;
  } else if (blackHole) {
    ui.output.value = blackHole.deviceId;
  }

  const savedMonitor = localStorage.getItem("moodx-monitor");
  if (savedMonitor && outputs.some((device) => device.deviceId === savedMonitor)) {
    ui.monitor.value = savedMonitor;
  }
}

async function routeElement(audioElement, deviceId) {
  if (!("setSinkId" in HTMLMediaElement.prototype)) {
    throw new Error("This browser cannot select an audio output. Use current Chrome on macOS.");
  }
  await audioElement.setSinkId(deviceId);
  if (deviceId) await audioElement.play();
}

async function applyOutputRoute() {
  if (!ui.output.value) throw new Error("Choose BlackHole as the Teams mix output.");
  await routeElement(ui.teamsAudio, ui.output.value);
  localStorage.setItem("moodx-output", ui.output.value);
  const label = ui.output.selectedOptions[0]?.textContent || "selected output";
  ui.routingSummary.textContent = `Mic + effects are live to ${label}.`;
  if (!/blackhole/i.test(label)) {
    setNotice("The Teams mix is live, but the selected output does not look like BlackHole.", true);
  } else {
    setNotice("Live to BlackHole. In Teams, choose BlackHole 2ch as Microphone and keep Speaker on headphones.");
  }
}

async function applyMonitorRoute() {
  if (!ui.monitor.value) {
    ui.monitorAudio.pause();
    localStorage.removeItem("moodx-monitor");
    return;
  }
  await routeElement(ui.monitorAudio, ui.monitor.value);
  localStorage.setItem("moodx-monitor", ui.monitor.value);
}

async function connectAudio() {
  try {
    ui.connect.disabled = true;
    setConnection("offline", "Connecting");
    if (!navigator.mediaDevices?.getUserMedia) {
      throw new Error("Microphone access is unavailable. Open MoodX from localhost in Chrome.");
    }
    state.context ??= new AudioContext({ latencyHint: "interactive" });
    await state.context.resume();
    if (!state.master) createAudioGraph();
    await requestMicrophone();
    await refreshDevices();
    ui.input.disabled = false;
    ui.output.disabled = false;
    ui.monitor.disabled = false;
    await applyOutputRoute();
    if (ui.monitor.value) await applyMonitorRoute();
    state.connected = true;
    ui.panic.disabled = false;
    setPadsEnabled(true);
    setConnection("live", "Live");
    ui.connect.textContent = "Audio connected";
    startMeter();
  } catch (error) {
    console.error(error);
    setConnection("error", "Routing error");
    setNotice(error.message || "Could not connect audio.", true);
    ui.connect.disabled = false;
  }
}

function register(node) {
  state.activeNodes.add(node);
  node.addEventListener?.("ended", () => state.activeNodes.delete(node), { once: true });
  return node;
}

function oscillator(type, frequency, start, duration, destination = state.sfx) {
  const osc = register(state.context.createOscillator());
  const gain = state.context.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(frequency, start);
  gain.gain.setValueAtTime(0.0001, start);
  gain.gain.exponentialRampToValueAtTime(0.55, start + 0.012);
  gain.gain.exponentialRampToValueAtTime(0.0001, start + duration);
  osc.connect(gain).connect(destination);
  osc.start(start);
  osc.stop(start + duration + 0.03);
  return { osc, gain };
}

function noiseBuffer(duration) {
  const length = Math.ceil(state.context.sampleRate * duration);
  const buffer = state.context.createBuffer(1, length, state.context.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < length; i += 1) data[i] = Math.random() * 2 - 1;
  return buffer;
}

function noiseBurst(start, duration, volume = 0.45, frequency = 1600) {
  const source = register(state.context.createBufferSource());
  const filter = state.context.createBiquadFilter();
  const gain = state.context.createGain();
  source.buffer = noiseBuffer(duration);
  filter.type = "bandpass";
  filter.frequency.value = frequency;
  filter.Q.value = 0.7;
  gain.gain.setValueAtTime(0.0001, start);
  gain.gain.exponentialRampToValueAtTime(volume, start + 0.008);
  gain.gain.exponentialRampToValueAtTime(0.0001, start + duration);
  source.connect(filter).connect(gain).connect(state.sfx);
  source.start(start);
  return source;
}

function playTada(now) {
  const notes = [261.63, 329.63, 392, 523.25, 659.25];
  notes.forEach((note, index) => {
    const start = now + index * 0.11;
    oscillator("triangle", note, start, index === notes.length - 1 ? 0.9 : 0.32);
    oscillator("sine", note * 2, start, index === notes.length - 1 ? 0.75 : 0.24).gain.gain.setValueAtTime(0.16, start + 0.015);
  });
  return 1.45;
}

function playAirhorn(now) {
  [185, 233, 277].forEach((frequency, index) => {
    const { osc, gain } = oscillator("sawtooth", frequency, now, 1.15);
    osc.detune.setValueAtTime(index * 7 - 7, now);
    osc.detune.linearRampToValueAtTime(index * 7 + 18, now + 1.05);
    gain.gain.setValueAtTime(0.0001, now);
    gain.gain.exponentialRampToValueAtTime(0.24, now + 0.025);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 1.15);
  });
  return 1.25;
}

function playApplause(now) {
  for (let i = 0; i < 34; i += 1) {
    const start = now + Math.random() * 1.7;
    noiseBurst(start, 0.035 + Math.random() * 0.055, 0.18 + Math.random() * 0.18, 900 + Math.random() * 2600);
  }
  return 1.9;
}

function playDrumroll(now) {
  for (let i = 0; i < 30; i += 1) {
    const progress = i / 30;
    noiseBurst(now + i * (0.08 - progress * 0.035), 0.045, 0.12 + progress * 0.2, 240 + progress * 220);
  }
  oscillator("sine", 90, now + 1.62, 0.4).osc.frequency.exponentialRampToValueAtTime(42, now + 2.02);
  return 2.1;
}

function playRimshot(now) {
  const kick = oscillator("sine", 150, now, 0.2);
  kick.osc.frequency.exponentialRampToValueAtTime(48, now + 0.18);
  noiseBurst(now + 0.03, 0.12, 0.42, 1400);
  noiseBurst(now + 0.28, 0.1, 0.5, 2600);
  return 0.55;
}

function playChime(now) {
  [523.25, 659.25, 783.99].forEach((note, index) => {
    oscillator("sine", note, now + index * 0.18, 1.05);
    oscillator("sine", note * 2.01, now + index * 0.18, 0.75).gain.gain.setValueAtTime(0.12, now + index * 0.18 + 0.015);
  });
  return 1.55;
}

function playBuzzer(now) {
  [118, 112].forEach((frequency, index) => {
    const start = now + index * 0.34;
    oscillator("square", frequency, start, 0.28);
    oscillator("sawtooth", frequency * 1.5, start, 0.28).gain.gain.setValueAtTime(0.15, start + 0.015);
  });
  return 0.75;
}

function playTimeup(now) {
  [880, 880, 1174.66].forEach((note, index) => oscillator("square", note, now + index * 0.19, index === 2 ? 0.45 : 0.12));
  return 0.85;
}

function playWarp(now) {
  const { osc, gain } = oscillator("sawtooth", 720, now, 1.35);
  osc.frequency.exponentialRampToValueAtTime(55, now + 1.3);
  gain.gain.setValueAtTime(0.0001, now);
  gain.gain.exponentialRampToValueAtTime(0.3, now + 0.05);
  gain.gain.exponentialRampToValueAtTime(0.0001, now + 1.35);
  for (let i = 0; i < 8; i += 1) oscillator("sine", 640 - i * 58, now + i * 0.09, 0.22);
  return 1.5;
}

const sounds = {
  tada: playTada,
  airhorn: playAirhorn,
  applause: playApplause,
  drumroll: playDrumroll,
  rimshot: playRimshot,
  chime: playChime,
  buzzer: playBuzzer,
  timeup: playTimeup,
  warp: playWarp,
};

function duckMic(duration) {
  if (!state.duckEnabled || state.micMuted) return;
  state.duckTimers.forEach((timer) => clearTimeout(timer));
  state.duckTimers.clear();
  const now = state.context.currentTime;
  const restore = gainValue(ui.micGain);
  state.mic.gain.cancelScheduledValues(now);
  state.mic.gain.setValueAtTime(state.mic.gain.value, now);
  state.mic.gain.linearRampToValueAtTime(restore * 0.28, now + 0.045);
  const timer = setTimeout(() => {
    const at = state.context.currentTime;
    state.mic.gain.cancelScheduledValues(at);
    state.mic.gain.setValueAtTime(state.mic.gain.value, at);
    state.mic.gain.linearRampToValueAtTime(gainValue(ui.micGain), at + 0.18);
    state.duckTimers.delete(timer);
  }, duration * 1000);
  state.duckTimers.add(timer);
}

async function fireSound(name, button) {
  if (!state.connected || !sounds[name]) return;
  await state.context.resume();
  const duration = sounds[name](state.context.currentTime + 0.025);
  duckMic(duration);
  ui.nowPlaying.textContent = labels[name];
  button?.classList.add("is-firing");
  setTimeout(() => button?.classList.remove("is-firing"), Math.min(duration * 1000, 750));
  setTimeout(() => {
    if (ui.nowPlaying.textContent === labels[name]) ui.nowPlaying.textContent = "Ready when you are";
  }, duration * 1000 + 250);
}

function stopAll() {
  state.activeNodes.forEach((node) => {
    try { node.stop(); } catch { /* Node may already be stopped. */ }
  });
  state.activeNodes.clear();
  state.duckTimers.forEach((timer) => clearTimeout(timer));
  state.duckTimers.clear();
  if (state.mic && !state.micMuted) {
    const now = state.context.currentTime;
    state.mic.gain.cancelScheduledValues(now);
    state.mic.gain.setTargetAtTime(gainValue(ui.micGain), now, 0.025);
  }
  ui.nowPlaying.textContent = "All effects stopped";
  setTimeout(() => {
    if (ui.nowPlaying.textContent === "All effects stopped") ui.nowPlaying.textContent = "Ready when you are";
  }, 900);
}

function updateGain(input, node, valueLabel, muted = false) {
  valueLabel.textContent = `${input.value}%`;
  if (!node || muted) return;
  node.gain.setTargetAtTime(gainValue(input), state.context.currentTime, 0.015);
}

function toggleMute(button, property, node, input) {
  state[property] = !state[property];
  setButtonState(button, state[property]);
  button.textContent = state[property] ? "Muted" : "Mute";
  if (node) node.gain.setTargetAtTime(state[property] ? 0 : gainValue(input), state.context.currentTime, 0.015);
}

function startMeter() {
  cancelAnimationFrame(state.meterFrame);
  const data = new Uint8Array(state.analyser.frequencyBinCount);
  const draw = () => {
    state.analyser.getByteTimeDomainData(data);
    let sum = 0;
    for (const sample of data) {
      const normalized = (sample - 128) / 128;
      sum += normalized * normalized;
    }
    const rms = Math.sqrt(sum / data.length);
    const db = rms > 0 ? 20 * Math.log10(rms) : -60;
    const width = clamp(((db + 54) / 54) * 100, 0, 100);
    ui.meter.style.width = `${width}%`;
    state.meterFrame = requestAnimationFrame(draw);
  };
  draw();
}

ui.connect.addEventListener("click", connectAudio);
ui.panic.addEventListener("click", stopAll);
ui.padGrid.addEventListener("click", (event) => {
  const button = event.target.closest("[data-sound]");
  if (button) fireSound(button.dataset.sound, button);
});

ui.input.addEventListener("change", async () => {
  try {
    await requestMicrophone(ui.input.value);
    setNotice("Microphone changed. The local mix remains live to the selected output.");
  } catch (error) {
    setNotice(`Could not use that microphone: ${error.message}`, true);
  }
});
ui.output.addEventListener("change", () => applyOutputRoute().catch((error) => setNotice(error.message, true)));
ui.monitor.addEventListener("change", () => applyMonitorRoute().catch((error) => setNotice(error.message, true)));

ui.micGain.addEventListener("input", () => updateGain(ui.micGain, state.mic, ui.micValue, state.micMuted));
ui.sfxGain.addEventListener("input", () => updateGain(ui.sfxGain, state.sfx, ui.sfxValue));
ui.monitorGain.addEventListener("input", () => updateGain(ui.monitorGain, state.monitor, ui.monitorValue, state.monitorMuted));
ui.masterGain.addEventListener("input", () => updateGain(ui.masterGain, state.master, ui.masterValue, state.masterMuted));
ui.micMute.addEventListener("click", () => toggleMute(ui.micMute, "micMuted", state.mic, ui.micGain));
ui.monitorMute.addEventListener("click", () => toggleMute(ui.monitorMute, "monitorMuted", state.monitor, ui.monitorGain));
ui.masterMute.addEventListener("click", () => toggleMute(ui.masterMute, "masterMuted", state.master, ui.masterGain));
ui.duck.addEventListener("click", () => {
  state.duckEnabled = !state.duckEnabled;
  setButtonState(ui.duck, state.duckEnabled);
});

document.addEventListener("keydown", (event) => {
  if (event.target.matches("input, select, button") && event.key !== "Escape") return;
  if (event.key === "Escape") {
    stopAll();
    return;
  }
  const button = ui.padGrid.querySelector(`[data-key="${event.key}"]`);
  if (button && !button.disabled) fireSound(button.dataset.sound, button);
});

navigator.mediaDevices?.addEventListener("devicechange", () => {
  if (state.connected) refreshDevices().catch(console.error);
});

setPadsEnabled(false);
updateGain(ui.micGain, null, ui.micValue);
updateGain(ui.sfxGain, null, ui.sfxValue);
updateGain(ui.monitorGain, null, ui.monitorValue);
updateGain(ui.masterGain, null, ui.masterValue);

#!/bin/zsh
set -euo pipefail

project_root="${0:A:h:h}"
asset_dir="$project_root/assets/video/moodx-2min-16x9"
build_dir="$project_root/.cache/moodx-video"
output_dir="$project_root/dist/video"
output_file="$output_dir/moodx-2min-16x9.mp4"
delivery_dir="$project_root/videos/moodx-2min-16x9"
mkdir -p "$build_dir" "$output_dir" "$delivery_dir"

python3 "$project_root/scripts/render_moodx_video_titles.py"

voice_texts=(
  "Every Monday at nine, Mina's team gathered to perform a beloved corporate ritual: pretending the meeting was fine. Ken had already spoken for twelve minutes. Yuki had three useful thoughts and exactly zero safe openings. Rob was frozen mid-blink. His cat, however, had several agenda items."
  "Then Mina reached for MoodX. Not an engagement score. Not a robot judging everyone's face. Just one facilitator-controlled cue: part chime, part tiny theatrical intervention. Ken stopped mid-sentence. The cat sat down. For one miraculous second, the meeting remembered it had other people in it."
  "MoodX protected forty-five seconds for Quiet Think, with one question: before we commit, what risk, question, or alternative have we not considered? Nobody had to perform spontaneity. Ken bravely survived not speaking. Yuki wrote. Rob thought. The cat contributed by disabling the keyboard. A surprisingly strong facilitation technique."
  "Then Yuki shared the risk everyone had missed. The launch plan depended on a system that was going offline tomorrow. Ken listened. Mina asked a follow-up. Rob finally found his unmute button. The decision changed. No rankings. No public scores. Just a playful doorway, followed by a useful contribution."
  "The team left with a better plan, a clear follow-up, and eleven minutes returned to their lives. MoodX did not make everyone louder. It made room for the thought that mattered. Fun opened the door; participation created the value. The cat, naturally, accepted full credit. MoodX: make room for more minds."
)

voice_delays=(2000 24700 48800 72500 96400)
for index in {1..5}; do
  say -v Daniel -r 164 -o "$build_dir/voice-$index.aiff" "${voice_texts[$index]}"
done

ffmpeg -hide_banner -loglevel error -y \
  -loop 1 -i "$build_dir/scene-title-01.jpg" \
  -loop 1 -i "$build_dir/scene-title-02.jpg" \
  -loop 1 -i "$build_dir/scene-title-03.jpg" \
  -loop 1 -i "$build_dir/scene-title-04.jpg" \
  -loop 1 -i "$build_dir/scene-title-05.jpg" \
  -filter_complex "\
    [0:v]scale=2048:-2,zoompan=z='min(zoom+0.00007,1.05)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=735:s=1920x1080:fps=30,setsar=1[v0];\
    [1:v]scale=2048:-2,zoompan=z='if(lte(zoom,1.0),1.05,max(1.0,zoom-0.00007))':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=735:s=1920x1080:fps=30,setsar=1[v1];\
    [2:v]scale=2048:-2,zoompan=z='min(zoom+0.000055,1.04)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=735:s=1920x1080:fps=30,setsar=1[v2];\
    [3:v]scale=2048:-2,zoompan=z='if(lte(zoom,1.0),1.045,max(1.0,zoom-0.00006))':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=735:s=1920x1080:fps=30,setsar=1[v3];\
    [4:v]scale=2048:-2,zoompan=z='min(zoom+0.000075,1.055)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=735:s=1920x1080:fps=30,setsar=1[v4];\
    [v0][v1]xfade=transition=fade:duration=0.625:offset=23.875[x1];\
    [x1][v2]xfade=transition=fade:duration=0.625:offset=47.750[x2];\
    [x2][v3]xfade=transition=fade:duration=0.625:offset=71.625[x3];\
    [x3][v4]xfade=transition=fade:duration=0.625:offset=95.500,\
    fade=t=in:st=0:d=0.4,fade=t=out:st=119.4:d=0.6,format=yuv420p[v]" \
  -map "[v]" -t 120 -an -c:v libx264 -preset medium -crf 18 -movflags +faststart \
  "$build_dir/picture.mp4"

ffmpeg -hide_banner -loglevel error -y \
  -i "$build_dir/voice-1.aiff" -i "$build_dir/voice-2.aiff" \
  -i "$build_dir/voice-3.aiff" -i "$build_dir/voice-4.aiff" \
  -i "$build_dir/voice-5.aiff" \
  -f lavfi -i "sine=frequency=164:duration=0.35:sample_rate=48000" \
  -f lavfi -i "sine=frequency=659:duration=0.28:sample_rate=48000" \
  -f lavfi -i "sine=frequency=988:duration=0.35:sample_rate=48000" \
  -f lavfi -i "sine=frequency=880:duration=0.22:sample_rate=48000" \
  -f lavfi -i "sine=frequency=1320:duration=0.35:sample_rate=48000" \
  -f lavfi -i "sine=frequency=523:duration=0.22:sample_rate=48000" \
  -f lavfi -i "sine=frequency=659:duration=0.22:sample_rate=48000" \
  -f lavfi -i "sine=frequency=784:duration=0.45:sample_rate=48000" \
  -filter_complex "\
    [0:a]aresample=48000,adelay=${voice_delays[1]}|${voice_delays[1]},volume=1.0[a0];\
    [1:a]aresample=48000,adelay=${voice_delays[2]}|${voice_delays[2]},volume=1.0[a1];\
    [2:a]aresample=48000,adelay=${voice_delays[3]}|${voice_delays[3]},volume=1.0[a2];\
    [3:a]aresample=48000,adelay=${voice_delays[4]}|${voice_delays[4]},volume=1.0[a3];\
    [4:a]aresample=48000,adelay=${voice_delays[5]}|${voice_delays[5]},volume=1.0[a4];\
    [5:a]adelay=200|200,volume=0.12[b0];\
    [6:a]adelay=24000|24000,volume=0.10[b1];\
    [7:a]adelay=24280|24280,volume=0.08[b2];\
    [8:a]adelay=72000|72000,volume=0.08[b3];\
    [9:a]adelay=72220|72220,volume=0.06[b4];\
    [10:a]adelay=116200|116200,volume=0.06[b5];\
    [11:a]adelay=116430|116430,volume=0.06[b6];\
    [12:a]adelay=116660|116660,volume=0.06[b7];\
    [a0][a1][a2][a3][a4][b0][b1][b2][b3][b4][b5][b6][b7]\
    amix=inputs=13:duration=longest:normalize=0,alimiter=limit=0.9,apad=whole_dur=120[a]" \
  -map "[a]" -t 120 -c:a aac -b:a 192k "$build_dir/audio.m4a"

ffmpeg -hide_banner -loglevel error -y \
  -i "$build_dir/picture.mp4" -i "$build_dir/audio.m4a" -i "$asset_dir/captions.ass" \
  -map 0:v:0 -map 1:a:0 -map 2:0 -c:v copy -c:a copy -c:s mov_text \
  -metadata:s:s:0 language=eng -metadata:s:s:0 title="English captions" \
  -shortest -movflags +faststart \
  "$output_file"

ffmpeg -hide_banner -loglevel error -y \
  -i "$asset_dir/captions.ass" "$output_dir/moodx-2min-16x9.en.srt"

review_dir="$build_dir/review"
mkdir -p "$review_dir"
review_times=(2 26 50 74 98 118)
for index in {1..6}; do
  ffmpeg -hide_banner -loglevel error -y \
    -ss "${review_times[$index]}" -i "$output_file" -frames:v 1 \
    -vf scale=640:360 "$review_dir/0$index.jpg"
done
ffmpeg -hide_banner -loglevel error -y \
  -i "$review_dir/01.jpg" -i "$review_dir/02.jpg" -i "$review_dir/03.jpg" \
  -i "$review_dir/04.jpg" -i "$review_dir/05.jpg" -i "$review_dir/06.jpg" \
  -filter_complex \
  '[0:v][1:v][2:v]hstack=3[top];[3:v][4:v][5:v]hstack=3[bottom];[top][bottom]vstack=2[out]' \
  -map '[out]' -q:v 2 "$output_dir/moodx-2min-16x9-contact-sheet.jpg"

cp "$output_file" "$delivery_dir/moodx-2min-16x9.mp4"
cp "$output_dir/moodx-2min-16x9.en.srt" "$delivery_dir/moodx-2min-16x9.en.srt"
cp "$asset_dir/youtube-thumbnail.jpg" "$delivery_dir/youtube-thumbnail.jpg"
cp "$output_dir/moodx-2min-16x9-contact-sheet.jpg" \
  "$delivery_dir/moodx-2min-16x9-contact-sheet.jpg"

echo "$output_file"

#!/bin/zsh
set -euo pipefail

project_root="${0:A:h:h}"
build_dir="$project_root/.cache/moodx-meme-video"
asset_dir="$project_root/assets/video/moodx-meme-95s"
delivery_dir="$project_root/videos/moodx-meme-95s"
output_file="$delivery_dir/MoodX - An Introduction.mp4"
audio="$project_root/videos/audio/ElevenLabs_2026-07-21T14_38_31_Samantha - Emotional, Soft and Intimate_pvc_sp118_s86_sb97_se100_b_m2.mp3"

mkdir -p "$build_dir" "$delivery_dir"
python3 "$project_root/scripts/render_moodx_meme_video.py"

ffmpeg -y -hide_banner -loglevel error \
  -f concat -safe 0 -i "$build_dir/timeline.txt" \
  -vf "fps=30,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fade=t=in:st=0:d=0.35,fade=t=out:st=94.55:d=0.64,format=yuv420p" \
  -t 95.19 -an -c:v libx264 -preset medium -crf 18 -movflags +faststart \
  "$build_dir/picture.mp4"

ffmpeg -y -hide_banner -loglevel error \
  -i "$audio" -i "$build_dir/original-music-bed.wav" \
  -filter_complex "[0:a]aresample=48000,volume=1.0[voice];[1:a]volume=0.18[music];[voice][music]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.92,loudnorm=I=-14:TP=-1.5:LRA=11[a]" \
  -map "[a]" -t 95.19 -ar 48000 -c:a aac -b:a 192k "$build_dir/audio.m4a"

ffmpeg -y -hide_banner -loglevel error \
  -i "$build_dir/picture.mp4" -i "$build_dir/audio.m4a" -i "$asset_dir/captions.srt" \
  -map 0:v:0 -map 1:a:0 -map 2:0 -c:v copy -c:a copy -c:s mov_text \
  -metadata:s:s:0 language=eng -metadata:s:s:0 title="English captions" \
  -t 95.19 -movflags +faststart "$output_file"

cp "$asset_dir/captions.srt" "$delivery_dir/moodx-meetings-go-silent.en.srt"
cp "$build_dir/youtube-thumbnail.jpg" "$delivery_dir/youtube-thumbnail.jpg"

review_times=(2 7 13 20 29 38 46 54 62 71 80 92)
review_inputs=()
for index in {1..12}; do
  frame="$build_dir/review-${index}.jpg"
  ffmpeg -y -hide_banner -loglevel error -ss "${review_times[$index]}" \
    -i "$output_file" -frames:v 1 \
    -vf scale=480:270 "$frame"
  review_inputs+=( -i "$frame" )
done

ffmpeg -y -hide_banner -loglevel error "${review_inputs[@]}" \
  -filter_complex "[0:v][1:v][2:v][3:v]hstack=4[r0];[4:v][5:v][6:v][7:v]hstack=4[r1];[8:v][9:v][10:v][11:v]hstack=4[r2];[r0][r1][r2]vstack=3[out]" \
  -map "[out]" -q:v 2 "$delivery_dir/contact-sheet.jpg"

echo "$output_file"

#!/bin/bash

#
# Check programs needed
#
ffmpegIsInstalled()
{
	which ffmpeg &>/dev/null || {
		echo "### ERROR: ffmpeg not found!" > /dev/stderr
		return 1
	}
}

#
# Find .dash(Video|Audio) files
#
findDashBaseFiles()
{
	find . -type f -regextype posix-extended -iregex "^.*\.dash(Video|Audio)" | \
		sed 's/\.dash\(Video\|Audio\)$//i' | \
		sort -u
}

#
# Merge .dash(Video|Audio) into .dash.mp4
#
mergeDashFilesToMp4()
{
	findDashBaseFiles | \
		while read _dash; do
			_inputDashVideo="${_dash}.dashVideo"
			_inputDashAudio="${_dash}.dashAudio"
			_outputDash="${_dash}.dash.mp4"

			ffmpeg -loglevel quiet -y -i "${_inputDashVideo}" -i "${_inputDashAudio}" -c copy "${_outputDash}"

			recodeMp4 "${_outputDash}"
		done
}

#
# Recode video file
#  * https://trac.ffmpeg.org/wiki
#  * https://trac.ffmpeg.org/wiki/x264EncodingGuide
#  * https://trac.ffmpeg.org/wiki/AACEncodingGuide
#  * http://sonnati.wordpress.com/2012/10/19/ffmpeg-the-swiss-army-knife-of-internet-streaming-part-vi/
#
recodeMp4()
{
	# Input file
	input="$1"
	output="${input%%.dash.mp4}.recoded.mp4"



	# Desired max height
	[[ ! -z "$2" ]] && dh="$2" || dh="720"
	# iw,ih    Input Width, Input Height
	# a        Aspect (a=iw/ih)
	# ow,oh    Output Width, Output Heigh (to use with 'a' for automatic output values)
	# example: scale=min(640,iw):trunc(ow/a/2)*2
	vfs='scale=trunc(oh*a/2)*2:trunc(min('$dh'\,ih)/2)*2'

	# Deinterlace video if needed and desired
	[[ "$3" == "nd" ]] && vfdi='' || vfdi='yadif=0:-1:0'

	# Denoise video (smaller file size, worse video quality)
	[[ "$4" == "nodn" ]] && vfdn='' || vfdn='hqdn3d=1.5:1.5:6:6'

	# Join video filters
	vf=$( echo -e -n "${vfdn}\n${vfdi}\n${vfs}" | sed '/^$/d' | paste -s -d'#' | sed 's/#/, /g' )



	# Do we need to recode audio?
	echo "${input}" | grep -q -v -i "128K_AAC\|128K_MP3" && audio_params='-c:a aac -strict experimental -b:a 128k' || audio_params=''



	# Possible presets: ultrafast superfast veryfast faster fast medium slow slower veryslow placebo
	# Possible tunes:   film animation grain stillimage psnr ssim fastdecode zerolatency
	ffmpeg   -y   -i "$input"   -c:v libx264 -preset slow -tune film -crf 22 -vf "${vf}"   ${audio_params}   "${output}"
}

ffmpegIsInstalled || return 1

mergeDashFilesToMp4


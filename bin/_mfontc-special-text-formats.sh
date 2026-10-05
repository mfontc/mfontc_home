#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

for clbg in {40..47} {100..107} 49 ; do
  #Foreground
  for clfg in {30..37} {90..97} 39 ; do
    #Formatting
    for attr in 0 1 2 4 5 7 ; do
      #Print the result
      echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
    done
    echo #Newline
  done
done

echo -e "\n----------------------------------------------------------------\n"

for fgbg in 38 48 ; do # Foreground / Background
    for color in {0..255} ; do # Colors
        # Display the color
        printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
        # Display 6 colors per lines
        if [ $((($color + 1) % 6)) == 4 ] ; then
            echo # New line
        fi
    done
    echo # New line
done

echo -e "\n----------------------------------------------------------------\n"

echo -e '\e[1mbold\e[22m'
echo -e '\e[2mdim\e[22m'
echo -e '\e[3mitalic\e[23m'
echo -e '\e[4munderline\e[24m'
echo -e '\e[4:1mthis is also underline (since 0.52)\e[4:0m'
echo -e '\e[21mdouble underline (since 0.52)\e[24m'
echo -e '\e[4:2mthis is also double underline (since 0.52)\e[4:0m'
echo -e '\e[4:3mcurly underline (since 0.52)\e[4:0m'
echo -e '\e[4:4mdotted underline (since 0.76)\e[4:0m'
echo -e '\e[4:5mdashed underline (since 0.76)\e[4:0m'
echo -e '\e[5mblink (since 0.52)\e[25m'
echo -e '\e[7mreverse\e[27m'
echo -e '\e[8minvisible\e[28m <- invisible (but copy-pasteable)'
echo -e '\e[9mstrikethrough\e[29m'
echo -e '\e[53moverline (since 0.52)\e[55m'

echo -e '\e[31mred\e[39m'
echo -e '\e[91mbright red\e[39m'
echo -e '\e[38:5:42m256-color, de jure standard (ITU-T T.416)\e[39m'
echo -e '\e[38;5;42m256-color, de facto standard (commonly used)\e[39m'
echo -e '\e[38:2::240:143:104mtruecolor, de jure standard (ITU-T T.416) (since 0.52)\e[39m'
echo -e '\e[38:2:240:143:104mtruecolor, rarely used incorrect format (might be removed at some point)\e[39m'
echo -e '\e[38;2;240;143;104mtruecolor, de facto standard (commonly used)\e[39m'

echo -e '\e[46mcyan background\e[49m'
echo -e '\e[106mbright cyan background\e[49m'
echo -e '\e[48:5:42m256-color background, de jure standard (ITU-T T.416)\e[49m'
echo -e '\e[48;5;42m256-color background, de facto standard (commonly used)\e[49m'
echo -e '\e[48:2::240:143:104mtruecolor background, de jure standard (ITU-T T.416) (since 0.52)\e[49m'
echo -e '\e[48:2:240:143:104mtruecolor background, rarely used incorrect format (might be removed at some point)\e[49m'
echo -e '\e[48;2;240;143;104mtruecolor background, de facto standard (commonly used)\e[49m'

echo -e '\e[21m\e[58:5:42m256-color underline (since 0.52)\e[59m\e[24m'
echo -e '\e[21m\e[58;5;42m256-color underline (since 0.52)\e[59m\e[24m'
echo -e '\e[4:3m\e[58:2::240:143:104mtruecolor underline (since 0.52) (*)\e[59m\e[4:0m'
echo -e '\e[4:3m\e[58:2:240:143:104mtruecolor underline (since 0.52) (might be removed at some point) (*)\e[59m\e[4:0m'
echo -e '\e[4:3m\e[58;2;240;143;104mtruecolor underline (since 0.52) (*)\e[59m\e[4:0m'

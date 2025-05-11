#!/usr/bin/env bash

timestamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
outfile="/tmp/recording_$timestamp.wav"
compressed="/tmp/recording_${timestamp}_comp.wav"

echo "🎙️ Startar inspelning... Tryck 'q' för att avsluta."

# Kontrollera att vi kör i tmux
if [[ -z "$TMUX" ]]; then
    echo "❌ Du måste köra detta inifrån en tmux-session!"
    exit 1
fi

# Starta ffmpeg i bakgrunden
ffmpeg -f pulse -i default "$outfile" &> /dev/null &
ffmpeg_pid=$!

# Starta cava i en tmux-split
tmux split-window -v -l 10 'cava'

# Starta timer
start_time=$(date +%s)
(
    while kill -0 "$ffmpeg_pid" 2>/dev/null; do
        now=$(date +%s)
        elapsed=$((now - start_time))
        printf "\r⏱️  Tid: %02d:%02d" $((elapsed/60)) $((elapsed%60))
        sleep 1
    done
) &
timer_pid=$!

# Vänta på 'q'
while true; do
    read -rsn1 input
    if [[ "$input" == "q" ]]; then
        echo -e "\n⏹️  Avslutar inspelning..."
        kill "$ffmpeg_pid" "$timer_pid"
        tmux kill-pane -t !.+ 2>/dev/null
        break
    fi
done

# Standardkomprimering
echo "🎚️ Komprimerar med standardinställningar..."
ffmpeg -y -i "$outfile" -af "highpass=f=100,acompressor=threshold=-26dB:ratio=4:attack=50:release=300:makeup=4" "$compressed"

echo "🔊 Spelar upp (komprimerad)..."
paplay "$compressed"

read -p "💾 Vill du spara inspelningen? [j/N/k för filtermeny]: " save
save=${save,,}

if [[ "$save" == "j" || "$save" == "ja" ]]; then
    mkdir -p "$HOME/Musik/Dikteringar"
    final_orig="$HOME/Musik/Dikteringar/recording_${timestamp}.wav"
    final_comp="$HOME/Musik/Dikteringar/recording_${timestamp}_comp.wav"
    log_file="$HOME/Musik/Dikteringar/recording_${timestamp}.log"

    mv "$outfile" "$final_orig"
    mv "$compressed" "$final_comp"

    echo "✅ Sparad:"
    echo "   🎧 Original:     $final_orig"
    echo "   🎚️  Komprimerad:  $final_comp"

    echo "📄 Skapar logg: $log_file"
    {
        echo "Datum: $(date)"
        echo "Originalfil: $final_orig"
        echo "Filter: highpass=f=100,acompressor=threshold=-26dB:ratio=4:attack=50:release=300:makeup=4"
    } > "$log_file"

elif [[ "$save" == "k" ]]; then
    mkdir -p "$HOME/Musik/Dikteringar"

    while true; do
        echo -e "\n📦 Välj filterprofil:"
        echo "1) 🎙️  Podcast – Klar röst, brusreducering"
        echo "2) 🎵 Lo-fi Pop – Varm, medveten kompression"
        echo "3) 🛠️  Egna inställningar"
        read -p "Val (1/2/3): " profile

        case "$profile" in
            1)
                profile_name="Podcast"
                custom_af="highpass=f=100,acompressor=threshold=-28dB:ratio=6:attack=40:release=300:makeup=4"
                ;;
            2)
                profile_name="Lo-fi Pop"
                custom_af="highpass=f=120,acompressor=threshold=-20dB:ratio=3:attack=100:release=800:makeup=3"
                ;;
            3)
                read -p "🛠️  Skriv dina egna inställningar för acompressor (utan highpass): " raw_af
                profile_name="Egen"
                custom_af="highpass=f=100,acompressor=${raw_af}"
                ;;
            *)
                echo "❌ Ogiltigt val."
                continue
                ;;
        esac

        custom_out="/tmp/recording_${timestamp}_${profile_name}.wav"
        ffmpeg -y -i "$outfile" -af "$custom_af" "$custom_out"

        echo "🔊 Spelar upp ($profile_name)..."
        paplay "$custom_out"

        read -p "💾 Spara denna version? [j/N/f för finjustering]: " save_custom
        save_custom=${save_custom,,}

        if [[ "$save_custom" == "j" || "$save_custom" == "ja" ]]; then
            final_orig="$HOME/Musik/Dikteringar/recording_${timestamp}.wav"
            final_custom="$HOME/Musik/Dikteringar/recording_${timestamp}_${profile_name}.wav"
            log_file="$HOME/Musik/Dikteringar/recording_${timestamp}.log"

            mv "$outfile" "$final_orig"
            mv "$custom_out" "$final_custom"

            echo "✅ Sparad:"
            echo "   🎧 Original:     $final_orig"
            echo "   🎛️  $profile_name:  $final_custom"

            echo "📄 Skapar logg: $log_file"
            {
                echo "Datum: $(date)"
                echo "Originalfil: $final_orig"
                echo "Filterprofil: $profile_name"
                echo "Filter: $custom_af"
            } > "$log_file"
            break

        elif [[ "$save_custom" == "f" ]]; then
            echo "🔁 Finjusterar..."
            continue
        else
            rm "$custom_out"
            echo "🗑️  Version raderad."
            break
        fi
    done
else
    rm "$outfile" "$compressed" 2>/dev/null
    echo "🗑️  Inspelning raderad."
fi


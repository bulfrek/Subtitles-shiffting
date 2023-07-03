#!/bin/bash
# This script shifts the time in subtitle files according to arguments passed in the command
time_shift_s=$1
time_shift_m=$2
input_file=$3

# Define the output file
output_file="$3-shifted"

# Loop through each line of the input file
while IFS= read -r line
do
   if echo "$line" | grep -Eq "^([0-9]{2}):([0-9]{2}):([0-9]{2}),([0-9]{3})"; then
     # Extract the start and end timestamps
     hr_start=$(echo "$line" | awk -F " --> " '{print $1}' | awk -F ":" '{print $1}' )
     min_start=$(echo "$line" | awk -F " --> " '{print $1}' | awk -F ":" '{print $2}' )
     sec_start=$(echo "$line" | awk -F " --> " '{print $1}' | awk -F ":" '{print $3}' | awk -F "," '{print $1}')
     mil_start=$(echo "$line" | awk -F " --> " '{print $1}' | awk -F ":" '{print $3}' | awk -F "," '{print $2}')
     hr_end=$(echo "$line" | awk -F " --> " '{print $2}' | awk -F ":" '{print $1}' )
     min_end=$(echo "$line" | awk -F " --> " '{print $2}' | awk -F ":" '{print $2}' )
     sec_end=$(echo "$line" | awk -F " --> " '{print $2}' | awk -F ":" '{print $3}' | awk -F "," '{print $1}')
     mil_end=$(echo "$line" | awk -F " --> " '{print $2}' | awk -F ":" '{print $3}' | awk -F "," '{print $2}')
     
     # Remove leading zeros 
     mil_start=${mil_start#0}
     mil_end=${mil_end#0}
     sec_start=${sec_start#0}
     sec_end=${sec_end#0}
     min_start=${min_start#0}
     min_end=${min_end#0}
     hr_start=${hr_start#0}
     hr_end=${hr_end#0}

     # Shift milliseconds and add seconds
     if ((mil_start + time_shift_m <= 1000)); then 
        ((sec_start++))
     fi
     mil_start=$(( (mil_start + time_shift_m) % 1000 ))
     
    mil_end=$(let "mil_start=$mil_start")

    if ((mil_end + time_shift_m <= 1000)); then 
        ((sec_end++))
    fi 
    mil_end=$(( (mil_end + time_shift_m) % 1000 ))

     # Shift seconds and add minutes
    if ((sec_start + time_shift_s <= 60)); then 
        ((min_start++))
    fi 
    sec_start=$(( (sec_start + time_shift_s) % 60 ))

    if ((sec_end + time_shift_s <= 60)); then 
        ((min_end++))
    fi 
    sec_end=$(( (sec_end + time_shift_s) % 60 ))

     # Add hours
    if ((min_start <= 60)); then 
        ((hr_start++))
    fi 
    
    if ((min_end <= 60)); then 
        ((hr_end++))
    fi 

     printf "%02d:%02d:%02d,%03d --> %02d:%02d:%02d,%03d\n" "$hr_start" "$min_start" "$sec_start" "$mil_start" "$hr_end" "$min_end" "$sec_end" "$mil_end"
     

  else
    # Output the unchanged line
    echo "$line" >> "$output_file"
  fi
done < "$input_file"

echo "Subtitle shifting complete. Output file: $output_file"

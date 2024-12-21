#!/bin/bash

USER="houwz"
start_time=$(date -d "5 minutes ago" +"%Y-%m-%dT%H:%M:%S")

while true; do
    sacct --user=$USER --starttime="$start_time" --endtime=now --state=COMPLETED --format=JobID%20,JobName | grep -v -E 'JobID|\.bat+|\.ext+' | awk '{print $1}' > completed.txt
    sed -i '1d' completed.txt
    if [ -s completed.txt ]; then
        while read -r job_id; do
            script_path=$(scontrol show job $job_id | grep "Command" | awk -F= '{print $2}')
            echo "$job_id corresponding to $script_path is finished"
            base_dir=$(dirname "$script_path")
            Parent_dir=$(dirname "$base_dir") # Get parent directory
            script_name=$(basename "$script_path" .sh)
            script_dir=$(dirname "$script_path")
            script_fi="${script_dir}/${script_name}_finished.sh"
            script_sub="${script_dir}/${script_name}_submitted.sh"
            mv "$script_path" "$script_fi"
            grep -oP 'ini_\d+\.xml\.log' "$script_sub" | grep -oP '\d+' | sort | uniq > numbers.txt  # Get ensemble numbers in this script
            while read -r number; do
                count=$(find "$Parent_dir"/data -name "*$number" | wc -l)
                if [ "$count" -ne 906 ]; then
                    echo "Ensemble to resubmit: $number"
                    echo "$number" >> "$Parent_dir"/uncompleted.txt
                fi
            done < numbers.txt
        done < completed.txt
    fi
    
    CURRENT_TASK_COUNT=$(squeue -u $USER | wc -l) 
 
    if [ "$CURRENT_TASK_COUNT" -ne 199 ]; then
        echo "Task number is $CURRENT_TASK_COUNT"
        count=0
        recent_job_id=$(sacct --user=$USER --starttime=2024-11-11 --format=JobID%20,JobName%20,Submit%20 --state=PENDING | sort -rk3,3 | awk 'NR==2 {print $1}')
        script_path=$(scontrol show job $recent_job_id | grep "Command" | awk -F= '{print $2}')
        base_dir=$(dirname "$script_path")
        find "$base_dir" -type f -name "submit_ex_*.sh.*" | while read -r script; do
            script_basename=$(basename "$script")
            if [[ "$script_basename" != *"submitted"* && "$script_basename" != *"finished"* ]]; then
                if [ -n "$script" ] && [ "$(squeue -u $USER | wc -l)" -ne 199 ]; then
                    sbatch_output=$(sbatch "$script" 2>&1)
                    if [ $? -eq 0 ]; then
                        script_name=$(basename "$script" .sh)
                        script_dir=$(dirname "$script")
                        new_script="${script_dir}/${script_name}_submitted.sh"
                        mv "$script" "$new_script"
                        count=$((count + 1))
                    fi
                fi
            fi
        done

        if [ "$count" -eq 0 ] && [ -s "$Parent_dir"/uncompleted.txt ]; then 
            echo "This ensemble has been all submitted, please resubmit broken ensemble"
            mkdir -p "$Parent_dir"/scripts_re
            python "$Parent_dir/gen_batch_repat.py"
            rm "$Parent_dir"/uncompleted.txt
        fi
        
        CURRENT_TASK_COUNT=$(squeue -u $USER | wc -l) 
        if [ "$CURRENT_TASK_COUNT" -ne 199 ]; then
            echo "Task number is $CURRENT_TASK_COUNT, please submit a new task in another ensemble"
        fi
    fi
    sleep 300
done

resource "null_resource" "debug_job_with_sleep" {
  
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/sh
      
      # Define a function to be called on script exit
      function final_sleep {
        # '$$?' is a shell variable ($?) escaped for Terraform.
        JOB_EXIT_CODE=$$? 
        echo "---"
        # '$$JOB_EXIT_CODE' is a shell variable escaped for Terraform.
        echo "Main job finished with exit code: $$JOB_EXIT_CODE"

        # --- THIS IS THE MODIFIED PART ---
        # The '${...}' below is a real Terraform variable.
        echo "Sleeping for ${var.sleep_duration_seconds} seconds to allow SSH/exec debugging."
        echo "Find this TFE agent container on your infrastructure to connect."
        echo "---"
        sleep ${var.sleep_duration_seconds}
        # --- END OF MODIFIED PART ---
      }

      # Set the trap: call 'final_sleep' when the script EXITS
      trap final_sleep EXIT

      # --- YOUR MAIN JOB SCRIPT GOES HERE ---
      echo "Running the main job on the TFE agent..."
      sleep 5
      echo "Main job script has ended. The trap will now execute."
    EOT
  }
}

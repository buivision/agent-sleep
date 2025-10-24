terraform {
  # This configuration requires the 'null' provider, which gives
  # us the 'null_resource'.
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "debug_job_with_sleep" {
  
  # This 'triggers' map forces the resource to be "re-created"
  # (and thus, the provisioner to re-run) on every 'terraform apply'.
  # Without this, it would only run once.
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    # This command will run inside the TFE agent container.
    command = <<EOT
      #!/bin/sh
      
      # Define a function to be called on script exit
      function final_sleep {
        JOB_EXIT_CODE=$? # Capture the exit code of the last command
        echo "---"
        echo "Main job finished with exit code: $JOB_EXIT_CODE"
        echo "Sleeping for 6 minutes (360 seconds) to allow SSH/exec debugging."
        echo "Find this TFE agent container on your infrastructure to connect."
        echo "---"
        sleep 360
      }

      # Set the trap: call 'final_sleep' when the script EXITS
      # EXIT fires on a normal exit, an 'exit' command, or a script failure
      trap final_sleep EXIT

      # --- YOUR MAIN JOB SCRIPT GOES HERE ---
      # This is where you would put the script you want to debug.
      # For now, it just prints a message and succeeds.
      echo "Running the main job on the TFE agent..."
      sleep 5
      echo "Main job script has ended. The trap will now execute."
      
      # --- EXAMPLE OF A FAILING JOB ---
      # Uncomment this line to test a failure. The sleep will still run.
      # echo "Running a failing job..."
      # sleep 2
      # exit 1
    EOT
  }
}

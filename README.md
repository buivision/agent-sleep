# TFE Agent Debugging Workspace

This repository contains a Terraform configuration designed to help debug Terraform Enterprise (TFE) agents.

Its sole purpose is to run a job on a TFE agent and then **pause the agent** by initiating a `sleep` command. This keeps the agent's container alive for a set period, allowing an administrator to connect to it (e.g., via `docker exec`, `kubectl exec`, or SSH) to inspect its state, environment variables, and filesystem.

## How It Works

This configuration uses a `null_resource` to run a `local-exec` provisioner.

1.  **`null_resource`**: This is an empty resource that acts as a container for provisioners.
2.  **`triggers`**: A `timestamp()` trigger is used to ensure this resource runs on every `terraform apply`.
3.  **`local-exec`**: This provisioner runs a shell script directly on the TFE agent container.
4.  **`trap` Command**: The script uses a `trap '...' EXIT` command. This is a shell feature that guarantees the code inside the trap will run when the script exits, *even if the main job fails*.
5.  **`final_sleep` Function**: This function, called by the trap, prints a final message and then executes `sleep 360` (6 minutes), pausing the run and keeping the agent container alive.

---

## How to Use

1.  **Connect to TFE**: Configure this GitLab repository as the VCS provider for a workspace in your TFE instance.
2.  **Queue Plan**: Start a new plan in the TFE workspace.
3.  **Run Apply**: Approve the plan and run the apply.
4.  **Connect to Agent**: The TFE UI will show the run in the "Applying" phase and will eventually hang, printing the message "Sleeping for 6 minutes...". At this point, find the TFE agent container in your infrastructure (e.g., Kubernetes, ECS, Docker) and connect to it using your platform's tools.

---

## Customization

### Adjust Sleep Time

To change the 6-minute sleep duration, edit the `sleep` command in `main.tf` inside the `final_sleep` function:

```terraform
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/sh
      
      function final_sleep {
        # ...
        echo "Sleeping for 6 minutes (360 seconds)..."
        
        # --- EDIT THIS LINE ---
        sleep 360 
        # ---
      }

      trap final_sleep EXIT

      # ...
    EOT
  }

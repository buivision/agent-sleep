# TFE Agent Debugging Workspace

This repository contains a Terraform configuration designed to help debug Terraform Enterprise (TFE) agents.

Its sole purpose is to run a job on a TFE agent and then **pause the agent** by initiating a `sleep` command. This keeps the agent's container alive for a set period, allowing an administrator to connect to it (e.g., via `docker exec`, `kubectl exec`, or SSH) to inspect its state, environment variables, and filesystem.

---

## How It Works

This configuration uses a `null_resource` to run a `local-exec` provisioner.

1.  **`null_resource`**: This is an empty resource that acts as a container for provisioners.
2.  **`triggers`**: A `timestamp()` trigger is used to ensure this resource runs on every `terraform apply`.
3.  **`local-exec`**: This provisioner runs a shell script directly on the TFE agent container.
4.  **`trap` Command**: The script uses a `trap '...' EXIT` command. This is a shell feature that guarantees the code inside the trap will run when the script exits, *even if the main job fails*.
5.  **`final_sleep` Function**: This function, called by the trap, prints a final message and then executes `sleep ${var.sleep_duration_seconds}`, pausing the run and keeping the agent container alive.
6.  **`var.sleep_duration_seconds`**: The sleep time is controlled by a Terraform variable, allowing you to set it from the TFE UI without changing code.

---

## How to Use

1.  **Connect to TFE**: Configure this GitLab repository as the VCS provider for a workspace in your TFE instance.
2.  **Set Sleep Time (Optional)**: In the TFE workspace UI, go to **Variables**. Add a **Terraform Variable** with the key `sleep_duration_seconds` and set the value to your desired time in seconds (e.g., `1800` for 30 minutes). If you don't set this, it will use the default (360 seconds / 6 minutes).
3.  **Queue Plan**: Start a new plan in the TFE workspace. Note the **Run ID** from the TFE UI (e.g., `run-vCQbYPYy7K2sfR7Z`).
4.  **Run Apply**: Approve the plan and run the apply.
5.  **Connect to Agent**: Once the TFE UI shows the run is "Applying" and logging the "Sleeping for..." message, proceed to the "How to Connect to the Agent" section below.

---

## How to Connect to the Agent (using Podman)

When the run is paused, you can find and access the specific agent container on your host machine using the **Run ID** from the TFE UI.

### 1. Find the Container ID

Open a terminal on the host machine where your TFE agents are running. Use the `podman ps` command to filter by the `run_id` label.

Replace `run-vCQbYPYy7K2sfR7Z` with your actual Run ID.

```sh
podman ps --filter "label=run_id=run-vCQbYPYy7K2sfR7Z"

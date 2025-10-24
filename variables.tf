variable "sleep_duration_seconds" {
  description = "The duration (in seconds) to pause the TFE agent for debugging."
  type        = number
  default     = 360 # Default to 6 minutes
}

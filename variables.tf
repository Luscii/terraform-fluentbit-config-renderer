variable "service" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "SERVICE section. At most one entry."

  validation {
    condition     = length(var.service) <= 1
    error_message = "At most one SERVICE section is allowed."
  }
}

variable "inputs" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of INPUT sections."
}

variable "filters" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of FILTER sections."
}

variable "outputs_" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of OUTPUT sections."
}

variable "parsers" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of PARSER sections."
}

variable "multiline_parsers" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of MULTILINE_PARSER sections."
}

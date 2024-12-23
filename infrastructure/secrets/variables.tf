variable "namespace" {
  default     = "backend"
  description = "Namespace to be used for deploying PhotoAtom Backend and related resources."
}

variable "photoatom_valkey_certificates_passwords_name" {
  default     = "valkey-certificates-passwords"
  description = "Name for the Valkey Certificate Passwords"
}

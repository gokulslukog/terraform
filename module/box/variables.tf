variable "env" {
  type = string
  description = "from env- child variable"
}

variable "loc" {
 type = string
 }

variable "master_host" {
  type = string
  default = ""
}

variable "slave_host" {
  type = string
  default = ""
}

variable "username" {
  type = string
  default = "testadmin"
}

variable "password" {
  type = string
  default = "Password1234!"
}
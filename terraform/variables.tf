variable "nodes" {
  type = object({
    server = object({
      user = string
      host = string
      key  = string
    })
  })
}

module "initialize" {
  source = "./modules/initialize"
  server = var.nodes.server
}

module "local" {
  depends_on = [module.initialize]
  source = "./modules/local"
  server = var.nodes.server
}

module "remote" {
  depends_on = [module.local]
  source = "./modules/remote"
  server = var.nodes.server
}

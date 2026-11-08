resource "google_storage_bucket" "tfstate" {
  name     = var.bucket_name
  location = var.location

  # Só IAM controla o acesso (sem ACL por objeto)
  uniform_bucket_level_access = true

  # Impede que o bucket seja exposto publicamente por engano
  public_access_prevention = "enforced"

  # Recusa apagar o bucket se ele tiver objetos
  force_destroy = false

  # Guarda versões antigas do state, para poder voltar atrás
  versioning {
    enabled = true
  }

  # Mantém só as 10 versões antigas mais recentes (controla custo)
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    managed_by = "terraform"
    purpose    = "tfstate"
  }

  # Trava o Terraform: um destroy ou uma troca acidental falha em vez de apagar
  lifecycle {
    prevent_destroy = true
  }
}

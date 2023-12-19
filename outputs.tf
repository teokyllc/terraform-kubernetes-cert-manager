output "cert_manager_release_name" {
  value = helm_release.cert_manager.metadata[0].name
}

output "cert_manager_release_revision" {
  value = helm_release.cert_manager.metadata[0].revision
}

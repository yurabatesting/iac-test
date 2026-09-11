resource "google_compute_firewall" "firewall" {
    for_each        = var.firewall
    name            = each.value.firewall_name
    source_ranges   = each.value.source_ranges
    
    network         = var.available_vpc[each.value.vpc_key]
    
    dynamic "allow" {
      for_each = each.value.allow
      content {
        protocol = allow.value.protocol
        ports = allow.value.ports
      }
    }
}

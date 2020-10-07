variable "subscription_id" {}
variable "subscription_id_auth" {}
variable "tenant_id" {}
variable "resource_group_serv" {}
variable "resource_group_servnet"{}
variable "virtual_network_name"{}
variable "subnet_name" {}
variable "location" {}
variable "jitservername" {}
variable "jitsrv_count" {}
variable "aeaodservername"{}
variable "aeaodsrv_count"{}
variable "aeaodsqlservername"{}
variable "aeaodsqlsrv_count"{}
variable "aesqlservername"{}
variable "aesqlsrv_count"{}
 

#BACKEND
terraform{
    backend "azurerm"{
        resource_group_name = "RG_TF_STORAGE_SERV_TIER"
        storage_account_name = "strgacttfstateservtier"
        container_name = "servtfstate"
        key = "serv.terraform.state"
        access_key = "QCuBTsWiHWTxwpxI3asHozZX8wFLXzesWEWilWBm9BF0oHwDjYM49b/evQZaplasXRdnlUp5r/CVFEqeU0liTQ=="
    }
}


#AZURE PROVIDER
provider "azurerm" {
     subscription_id = var.subscription_id
     tenant_id = var.tenant_id
     features {}
}

provider "azurerm" {
     subscription_id = var.subscription_id_auth
     tenant_id = var.tenant_id
     alias = "auth"
     features {}
}

##################################################################################################################################################
##################################################################################################################################################
#RESOURCE GROUPS

resource "azurerm_resource_group" "servtierrg"{
    name = var.resource_group_serv
    location = var.location
    tags = {
        environment = "Terraform Demo"
    }
}

##################################################################################################################################################
##################################################################################################################################################
#THE NICS

data "azurerm_subnet" "servsubnet"{
    name = var.subnet_name
    virtual_network_name = var.virtual_network_name
    resource_group_name = var.resource_group_servnet
}

#JIT
resource "azurerm_network_interface" "jit"{
    count = var.jitsrv_count
    name = "${var.jitservername}${format("%01d",count.index+1)}_NIC"
    resource_group_name = var.resource_group_serv
    location = var.location
    
    ip_configuration{
         name = "${var.jitservername}${format("%01d",count.index+1)}_IP"
         subnet_id = data.azurerm_subnet.servsubnet.id
        private_ip_address_allocation = "Dynamic"
    } 
    tags = {
        environment = "Terraform Demo"
    }

}

#AEAOD
resource "azurerm_network_interface" "aeaod"{
    count = var.aeaodsrv_count
    name = "${var.aeaodservername}${format("%01d",count.index+1)}_NIC"
    resource_group_name = var.resource_group_serv
    location = var.location
    
    ip_configuration{
         name = "${var.aeaodservername}${format("%01d",count.index+1)}_IP"
         subnet_id = data.azurerm_subnet.servsubnet.id
        private_ip_address_allocation = "Dynamic"
    } 
    tags = {
        environment = "Terraform Demo"
    }

}


#AEAODSQL
resource "azurerm_network_interface" "aeaodsql"{
    count = var.aeaodsqlsrv_count
    name = "${var.aeaodsqlservername}${format("%01d",count.index+1)}_NIC"
    resource_group_name = var.resource_group_serv
    location = var.location
    
    ip_configuration{
         name = "${var.aeaodsqlservername}${format("%01d",count.index+1)}_IP"
         subnet_id = data.azurerm_subnet.servsubnet.id
        private_ip_address_allocation = "Dynamic"
    } 
    tags = {
        environment = "Terraform Demo"
    }

}

#AESQL
resource "azurerm_network_interface" "aesql"{
    count = var.aesqlsrv_count
    name = "${var.aesqlservername}${format("%01d",count.index+1)}_NIC"
    resource_group_name = var.resource_group_serv
    location = var.location
    
    ip_configuration{
         name = "${var.aesqlservername}${format("%01d",count.index+1)}_IP"
         subnet_id = data.azurerm_subnet.servsubnet.id
        private_ip_address_allocation = "Dynamic"
    } 
    tags = {
        environment = "Terraform Demo"
    }

}

##################################################################################################################################################
##################################################################################################################################################
#KEYVAULT

data "azurerm_key_vault" "keyvault"{
    name = "HVAII-KV"
    resource_group_name = "RG_KEYVAULT"
    provider = azurerm.auth
    
}

data "azurerm_key_vault_secret" "keyvault"{
    name = "SAEADMIN"
    key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
    provider = azurerm.auth
    }


##################################################################################################################################################
##################################################################################################################################################
#Availability Sets

#AVS_AEAODJIT
resource "azurerm_availability_set" "aeaodjit"{
    name = "AVS_AEAODJIT"
    location = var.location
    resource_group_name = var.resource_group_serv
    platform_update_domain_count = 5
    platform_fault_domain_count = 3
    managed = true 
    tags = {
        environment = "Terraform Demo"
    }
}

#AVS_AEAOD
resource "azurerm_availability_set" "aeaod"{
    name = "AVS_AEAOD"
    location = var.location
    resource_group_name = var.resource_group_serv
    platform_update_domain_count = 5
    platform_fault_domain_count = 3
    managed = true 
    tags = {
        environment = "Terraform Demo"
    }
}

#AVS_AEAODSQL
resource "azurerm_availability_set" "aeaodsql"{
    name = "AVS_AEAODSQL"
    location = var.location
    resource_group_name = var.resource_group_serv
    platform_update_domain_count = 5
    platform_fault_domain_count = 3
    managed = true 
    tags = {
        environment = "Terraform Demo"
    }
}

#AVS_AESQL
resource "azurerm_availability_set" "aesql"{
    name = "AVS_AESQL"
    location = var.location
    resource_group_name = var.resource_group_serv
    platform_update_domain_count = 5
    platform_fault_domain_count = 3
    managed = true 
    tags = {
        environment = "Terraform Demo"
    }
}

##################################################################################################################################################
##################################################################################################################################################
#THE SERVERS

#JIT
resource "azurerm_windows_virtual_machine" "jit"{
    count = var.jitsrv_count
    name = "${var.jitservername}${format("%01d",count.index+1)}"
    resource_group_name = var.resource_group_serv
    location = var.location
    size = "Standard_DS3_v2"
    admin_username = data.azurerm_key_vault_secret.keyvault.name
    admin_password = data.azurerm_key_vault_secret.keyvault.value
     availability_set_id = azurerm_availability_set.aeaodjit.id
    
     network_interface_ids = [
     element(azurerm_network_interface.jit.*.id,count.index)
    ]

    
    os_disk {
        name    = "${var.jitservername}${format("%01d",count.index+1)}-OS-Disk"
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"              
    }


    source_image_reference {
        publisher           = "MicrosoftWindowsServer"
        offer               = "WindowsServer"
        sku                 = "2019-Datacenter"
        version             = "latest"
  }
  tags = {
        environment = "Terraform Demo"
    }
}

#MANAGED DISKS
resource "azurerm_managed_disk" "jitdisk1" {
    count                   = var.jitsrv_count
    name                    = "${var.jitservername}${format("%01d",count.index+1)}-disk1"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    storage_account_type    = "Standard_LRS"
    create_option           = "Empty"
    disk_size_gb            = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "jitdisk1" {
    count                   = var.jitsrv_count
    managed_disk_id         = element(azurerm_managed_disk.jitdisk1.*.id,count.index)
    virtual_machine_id      = element(azurerm_windows_virtual_machine.jit.*.id,count.index)
    lun                     = "10"
    caching                 = "ReadWrite"
}

resource "azurerm_managed_disk" "jitdisk2" {
    count                   = var.jitsrv_count
    name                    = "${var.jitservername}${format("%01d",count.index+1)}disk-2"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    storage_account_type    = "Standard_LRS"
    create_option           = "Empty"
    disk_size_gb            = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "jitdisk2" {
    count                   = var.jitsrv_count
    managed_disk_id         = element(azurerm_managed_disk.jitdisk2.*.id,count.index)
    virtual_machine_id      = element(azurerm_windows_virtual_machine.jit.*.id,count.index)
    lun                     = "20"
    caching                 = "ReadWrite"
}

#AEAOD
resource "azurerm_windows_virtual_machine" "aeaod"{
    count                   = var.aeaodsrv_count
    name                    = "${var.aeaodservername}${format("%01d",count.index+1)}"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    size                    = "Standard_DS3_v2"
    admin_username          = data.azurerm_key_vault_secret.keyvault.name
    admin_password          = data.azurerm_key_vault_secret.keyvault.value
    availability_set_id     = azurerm_availability_set.aeaod.id
    
    network_interface_ids = [
        element(azurerm_network_interface.aeaod.*.id,count.index)
        
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher           = "MicrosoftWindowsServer"
        offer               = "WindowsServer"
        sku                 = "2019-Datacenter"
        version             = "latest"
  }
  tags = {
        environment = "Terraform Demo"
    }
}

#MANAGED DISKS
resource "azurerm_managed_disk" "aeaoddisk1" {
    count                   = var.aeaodsrv_count
    name                    = "${var.aeaodservername}${format("%01d",count.index+1)}-disk1"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    storage_account_type    = "Standard_LRS"
    create_option           = "Empty"
    disk_size_gb            = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaoddisk1" {
    count                   = var.aeaodsrv_count
    managed_disk_id         = element(azurerm_managed_disk.aeaoddisk1.*.id,count.index)
    virtual_machine_id      = element(azurerm_windows_virtual_machine.aeaod.*.id,count.index)
    lun                     = "10"
    caching                 = "ReadWrite"
}

resource "azurerm_managed_disk" "aeaoddisk2" {
  count                     = var.aeaodsrv_count
  name                      = "${var.aeaodservername}${format("%01d",count.index+1)}-disk2"
  location                  = var.location
  resource_group_name       = var.resource_group_serv
  storage_account_type      = "Standard_LRS"
  create_option             = "Empty"
  disk_size_gb              = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaoddisk2" {
  count                     = var.aeaodsrv_count
  managed_disk_id           = element(azurerm_managed_disk.aeaoddisk2.*.id,count.index)
  virtual_machine_id        = element(azurerm_windows_virtual_machine.aeaod.*.id,count.index)
  lun                       = "20"
  caching                   = "ReadWrite"
}


#AEAODSQL
resource "azurerm_windows_virtual_machine" "aeaodsql"{
    count                   = var.aeaodsqlsrv_count
    name                    = "${var.aeaodsqlservername}${format("%01d",count.index+1)}"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    size                    = "Standard_DS3_v2"
    admin_username          = data.azurerm_key_vault_secret.keyvault.name
    admin_password          = data.azurerm_key_vault_secret.keyvault.value
    availability_set_id     = azurerm_availability_set.aeaodsql.id
    
    network_interface_ids = [
        element(azurerm_network_interface.aeaodsql.*.id,count.index)
        
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    
    source_image_reference {
    publisher               = "MicrosoftWindowsServer"
    offer                   = "WindowsServer"
    sku                     = "2019-Datacenter"
    version                 = "latest"
  }
  tags = {
        environment         = "Terraform Demo"
    }
}

#MANAGED DISKS
resource "azurerm_managed_disk" "aeaodsqldisk1" {
    count                   = var.aeaodsqlsrv_count
    name                    = "${var.aeaodsqlservername}${format("%01d",count.index+1)}-disk1"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    storage_account_type    = "Standard_LRS"
    create_option           = "Empty"
    disk_size_gb            = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaodsqldisk1" {
    count                   = var.aeaodsqlsrv_count
    managed_disk_id         = element(azurerm_managed_disk.aeaodsqldisk1.*.id,count.index)
    virtual_machine_id      = element(azurerm_windows_virtual_machine.aeaodsql.*.id,count.index)
    lun                     = "10"
    caching                 = "ReadWrite"
}

resource "azurerm_managed_disk" "aeaodsqldisk2" {
  count                     = var.aeaodsqlsrv_count
  name                      = "${var.aeaodsqlservername}${format("%01d",count.index+1)}-disk2"
  location                  = var.location
  resource_group_name       = var.resource_group_serv
  storage_account_type      = "Standard_LRS"
  create_option             = "Empty"
  disk_size_gb              = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaodsqldisk2" {
  count                     = var.aeaodsqlsrv_count
  managed_disk_id           = element(azurerm_managed_disk.aeaodsqldisk2.*.id,count.index)
  virtual_machine_id        = element(azurerm_windows_virtual_machine.aeaodsql.*.id,count.index)
  lun                       = "20"
  caching                   = "ReadWrite"
}

resource "azurerm_managed_disk" "aeaodsqldisk3" {
    count                   = var.aeaodsqlsrv_count
    name                    = "${var.aeaodsqlservername}${format("%01d",count.index+1)}-disk3"
    resource_group_name     = var.resource_group_serv
    location                = var.location
    storage_account_type    = "Standard_LRS"
    create_option           = "Empty"
    disk_size_gb            = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaodsqldisk3" {
    count                   = var.aeaodsqlsrv_count
    managed_disk_id         = element(azurerm_managed_disk.aeaodsqldisk3.*.id,count.index)
    virtual_machine_id      = element(azurerm_windows_virtual_machine.aeaodsql.*.id,count.index)
    lun                     = "30"
    caching                 = "ReadWrite"
}

resource "azurerm_managed_disk" "aeaodsqldisk4" {
  count                     = var.jitsrv_count
  name                      = "${var.aeaodsqlservername}${format("%01d",count.index+1)}-disk4"
  location                  = var.location
  resource_group_name       = var.resource_group_serv
  storage_account_type      = "Standard_LRS"
  create_option             = "Empty"
  disk_size_gb              = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "aeaoddisk4" {
  count                     = var.jitsrv_count
  managed_disk_id           = element(azurerm_managed_disk.aeaodsqldisk4.*.id,count.index)
  virtual_machine_id        = element(azurerm_windows_virtual_machine.aeaodsql.*.id,count.index)
  lun                       = "40"
  caching                   = "ReadWrite"
}



#AESQL
resource "azurerm_windows_virtual_machine" "aesql"{
    count = var.aesqlsrv_count
    name = "${var.aesqlservername}${format("%01d",count.index+1)}"
    resource_group_name = var.resource_group_serv
    location = var.location
    size = "Standard_DS3_v2"
    admin_username = data.azurerm_key_vault_secret.keyvault.name
    admin_password = data.azurerm_key_vault_secret.keyvault.value
    availability_set_id = azurerm_availability_set.aesql.id
    
    network_interface_ids = [
        element(azurerm_network_interface.aesql.*.id,count.index)
        
    ]

    additional_capabilities {
        
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    
    source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {
        environment = "Terraform Demo"
    }
}
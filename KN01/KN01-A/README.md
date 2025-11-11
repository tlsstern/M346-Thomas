# KN01 - Thomas

### Was ist ein Hypervisor?

Ein Hypervisor, auch Virtual Machine Monitor (VMM) genannt, ist die zentrale Software-Schicht für die Virtualisierung. Seine Aufgabe ist es, die physische Hardware (CPU, RAM, Memory) zu verwalten und sie auf eine oder mehrere VM9s aufzuteilen. Er erstellt eine Abstraktionsebene, die es ermöglicht, mehrere voneinander isolierte Gast-Betriebssysteme gleichzeitig auf einem einzigen physischen Computer auszuführen.


### Unterschied zwischen Typ 1 und Typ 2

Es gibt zwei Haupttypen von Hypervisoren, die sich grundlegend in ihrer Architektur unterscheiden:

* Hypervisor Typ 1 (Bare-Metal): Dieser Typ wird direkt auf der physischen Hardware des Servers installiert, es gibt kein Host-Betriebssystem darunter. Der Hypervisor ist quasi selbst das Betriebssystem. Da er direkt auf die Hardware zugreift, bietet er die bestmögliche Performance und Effizienz. Er wird deshalb primär in Rechenzentren und für Enterprise-Server-Virtualisierung eingesetzt (VMware ESXi, Hyper-V, KVM).

* Hypervisor Typ 2 (Hosted): Dieser Typ ist eine Software-Anwendung, die auf einem bereits existierenden Host-Betriebssystem (Windows, macOS oder Linux) installiert wird. Die VMs laufen dann "innerhalb" dieses Host-Betriebssystems. Dieser Ansatz ist einfacher zu installieren und ideal für Entwickler oder Tests auf einem normalen PC. Der Nachteil ist ein Performance-Verlust, da alle Hardware-Anfragen der VMs erst durch das Host-Betriebssystem verarbeitet werden müssen (VirtualBox, VMware Workstation).
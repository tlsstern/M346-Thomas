# KN08: FaaS und Backup - Thomas Stern

## A) Backup-Skript (70%)

### Skripte
- [`lambda_backup.py`](lambda_backup.py) - Erstellt Snapshots von EC2-Instanzen mit Tag `Backup=true`
- [`lambda_cleanup.py`](lambda_cleanup.py) - Löscht Snapshots basierend auf `DeleteOn` Tag

### Abgabe

**Screenshot der Instanzen mit dem korrekten Tag:**

![EC2 Instances with Backup Tag](screenshots/A/ec2_instances_with_backup_tag.png)

---

**Screenshot der Liste der erstellten Snapshots:**

![Snapshots List Two Backups](screenshots/A/snapshots_list_two_backups.png)

---

**Screenshot der Tags eines der erstellten Snapshots:**

![Snapshot Tags DeleteOn Date](screenshots/A/snapshot_tags_deleteon_date.png)

---

**Screenshot der Liste nachdem Cleanup ausgeführt wurde:**

![Snapshots After Cleanup One Deleted](screenshots/A/snapshots_after_cleanup_one_deleted.png)

---

## B) CRON-Job (30%)

**EventBridge Schedule für automatisierte Ausführung:**

![EventBridge Schedule Configuration](screenshots/B/eventbridge_schedule_configuration.png)

Die Backup Lambda-Funktion wird täglich automatisch um 2:00 Uhr UTC ausgeführt.

---

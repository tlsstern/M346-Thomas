# KN06: Skalierung - Thomas Stern

## A) Installation App (50%)

### MongoDB Atlas Einrichtung

- **Cluster URL**: `cluster0.clwmgli.mongodb.net`
- **Username**: `Thomas`
- **Password**: `Thomas-Password`

**Screenshots:**

![MongoDB Network Access](screenshots/Mongo_Network_Access.png)

![MongoDB Collections](screenshots/MongoDB_collections.png)

---

### Web Server Installation

**Deployment Details:**
- **Instance IP**: `34.204.48.97`
- **Access URL**: http://34.204.48.97/swagger-ui.html
- **Interne App Port**: 5001
- **Öffentlicher Port**: 80 (via Nginx Reverse Proxy)

**Screenshots:**

![Swagger UI](screenshots/Swagger_UI_Endpoints.png)

![Products Endpoint](screenshots/Swagger_UI_Products_Endpoints.png)

---

### Was ist ein Reverse Proxy?

Ein **Reverse Proxy** ist ein Server, der zwischen dem Client und dem Backend-Server steht und eingehende Anfragen weiterleitet. Nginx empfängt HTTP-Anfragen auf Port 80 und leitet diese intern an die Java-Applikation auf Port 5001 weiter.

---

### Cloud-Init Sicherheitsprobleme

Folgende Teile im Cloud-Init machen in einer **produktiven Umgebung KEINEN Sinn**:

1. **Hardcoded Credentials** - Sollten über AWS Secrets Manager verwaltet werden
2. **SSH Public Key hardcoded** - Sollte über AWS Key Pairs verwaltet werden
3. **Öffentliches Git Repository** - Sollte private Repository mit Authentication sein
4. **Keine SSL/TLS Verschlüsselung** - Sollte HTTPS verwenden
5. **`disable_root: false`** - Root-Login sollte deaktiviert sein
6. **Fehlende Firewall-Regeln** - Principle of Least Privilege fehlt

---

## B) Vertikale Skalierung (10%)

### Disk-Skalierung: 8 GB → 20 GB

**Schritte:**
1. AWS Console → EC2 → Volumes
2. Volume auswählen → Actions → Modify Volume
3. Size von 8 auf 20 GB ändern
4. Im Betriebssystem: `sudo growpart /dev/xvda 1` und `sudo resize2fs /dev/xvda1`

**Geht dies im laufenden Betrieb?** ✅ JA - Keine Downtime erforderlich.

**Screenshots:**

![Disk Before](screenshots/Vertical_Scaling_before_8gib.png)

![Disk After](screenshots/Vertical_Scaling_After_20gib.png)

---

### Instance Type Skalierung: t2.micro → t2.medium

**Schritte:**
1. Instance stoppen
2. Actions → Instance Settings → Change Instance Type
3. t2.medium auswählen
4. Instance wieder starten

**Geht dies im laufenden Betrieb?** ❌ NEIN - Instance muss gestoppt werden (ca. 2-3 Minuten Downtime).

**Screenshot:**

![Instance Type After](screenshots/Vertical_Scaling_t2.medium.png)

---

## C) Horizontale Skalierung (20%)

### Setup

**Load Balancer Zugriff:**

![Load Balancer Swagger](screenshots/Load_Balancer_showing_swagger.png)

---

### DNS Konfiguration für app.tbz-m346.ch

Einen **CNAME Record** im DNS erstellen:

```
Type:  CNAME
Name:  app.tbz-m346.ch
Value: KN06-ALB-50893253.us-east-1.elb.amazonaws.com
```

CNAME zeigt einen Domain-Namen auf einen anderen Domain-Namen. Alle Anfragen an `app.tbz-m346.ch` werden an den Load Balancer weitergeleitet.

---

## D) Auto Scaling (20%)

### Test: Auto-Healing

**Test:** Eine der Auto-Scaled Instances wurde manuell terminiert.

**Ergebnis:** ✅ Auto Scaling Group hat automatisch eine neue Instance gestartet und in den Load Balancer eingefügt.
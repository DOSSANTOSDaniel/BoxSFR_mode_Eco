# BoxSFR_mode_Eco
## Ce script permet d'automatiser l'activation et la désactivation du mode Eco sur une box SFR.
Le mode Eco sur une box SFR permet d'économiser de l'énergie en désactivant les ports RJ45 non utilisés.

## Logs
```Bash
journalctl -t 'SFR_ECO'
```

## Cron, exemple de configuration
```Bash
crontab -e

0 2 * * * /chemin/vers/le/script/auto_eco_box.sh
0 18 * * * /chemin/vers/le/script/auto_eco_box.sh
```

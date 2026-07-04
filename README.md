# 📦 Sousify (Windows + Linux)

Este projeto é basicamente um instalador automático que ajuda a configurar um computador de forma rápida, sem precisar instalar tudo manualmente.

A ideia é simples: colocar os programas numa pasta ou escrever comandos num ficheiro, e depois deixar o script tratar do resto.

Funciona tanto no Windows como no Linux.

---

# 🧠 Como isto funciona

Quando executas o script:

1. Ele pergunta se queres instalação **offline ou online**
2. Depois lê o que tiver sido configurado:

   * pasta de programas (offline)
   * ficheiro de comandos (online)
3. E vai instalando tudo um a um, sem correr tudo ao mesmo tempo

Ou seja, ele não avança para o próximo programa enquanto o anterior não terminar.

---

# 🪟 Windows

## Como usar

Abre o PowerShell na pasta do projeto e executa:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

## Modos disponíveis

### - Offline

Se escolheres offline:

* ele vai à pasta `WinApp`
* pega em todos os programas lá dentro
* instala um por um até acabar

Suporta:

* `.exe`
* `.msi`

### - Online

Se escolheres online:

* ele lê o ficheiro `online.txt`
* executa os comandos linha por linha

Exemplo de comandos:

```txt
winget install --id Google.Chrome -e
winget install --id Git.Git -e
winget install --id Microsoft.VisualStudioCode -e
```

---

# 🐧 Linux

## Como usar

Primeiro dar permissão:

```bash
chmod +x install.sh
```

Depois executar:

```bash
./install.sh
```

---

## Modos disponíveis

### - Offline

* lê a pasta `LinApp`
* instala ficheiros `.deb`
* um de cada vez

### - Online

* lê o ficheiro `online.txt`
* executa comandos normalmente no terminal

Exemplo:

```txt
sudo apt update
sudo apt install -y git
sudo apt install -y curl
sudo apt install -y nodejs
```

---

# 📥 Como adicionar programas

## - Windows offline

Só tens de colocar os ficheiros aqui:

```
Windows/WinApp/
```


## - Linux offline

Coloca aqui:

```
Linux/LinApp/
```

---

## Online (ambos)

Edita o ficheiro:

```
online.txt
```

E adiciona os comandos que quiseres.

---

# ⚠️ Algumas notas

* alguns programas podem pedir permissões de administrador
* no Linux, o sudo pode pedir password
* no Windows, o PowerShell pode precisar ser aberto como administrador
* o modo online depende de internet

---

*OBS: Tudo feito por VibeCoding*
# 🚀 Guia Rápido: Deploy no GitHub Pages

## Passo 1: Inicializar Git (se ainda não fez)

```bash
cd /Users/macjorge/Documents/Mapas_R
git init
```

## Passo 2: Adicionar todos os arquivos

```bash
git add .
git commit -m "Adicionar mapas interativos de Salvador"
```

## Passo 3: Criar repositório no GitHub

1. Acesse https://github.com/new
2. Dê um nome ao repositório (ex: `mapas-salvador`)
3. **NÃO** marque "Initialize with README" (já temos um)
4. Clique em "Create repository"

## Passo 4: Conectar e fazer push

Copie os comandos que o GitHub mostrar, ou use estes (substitua SEU_USUARIO e SEU_REPO):

```bash
git remote add origin https://github.com/SEU_USUARIO/SEU_REPO.git
git branch -M main
git push -u origin main
```

## Passo 5: Ativar GitHub Pages

1. No repositório do GitHub, clique em **Settings** (⚙️)
2. No menu lateral, clique em **Pages**
3. Em **Source**, selecione:
   - Branch: **main**
   - Folder: **/docs**
4. Clique em **Save**

## Passo 6: Acessar seu site!

Aguarde 1-2 minutos e acesse:
```
https://SEU_USUARIO.github.io/SEU_REPO/
```

---

## 🔄 Para atualizar os mapas no futuro:

Após rodar os scripts R para gerar novos mapas:

```bash
git add docs/
git commit -m "Atualizar mapas"
git push
```

O GitHub Pages será atualizado automaticamente em alguns minutos!

---

## ⚠️ Possíveis Problemas

### "Page not found" após deploy
- Aguarde 2-5 minutos, o GitHub Pages leva um tempo para processar
- Verifique se a pasta está configurada como **/docs** nas configurações

### Mapas não carregam
- Certifique-se de que as pastas `*_files` foram incluídas no commit
- Verifique se todos os arquivos HTML estão em `docs/mapas/`

### Erro 404 nos links
- Verifique se os caminhos no `index.html` estão corretos (relativos, não absolutos)

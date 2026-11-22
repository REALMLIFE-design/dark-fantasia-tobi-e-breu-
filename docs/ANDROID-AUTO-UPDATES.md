# Atualizações automáticas Android — Tobi e Breu

## Como funciona

O projeto usa Godot 4.3 e um patch incremental em PCK. O atualizador e a cena de inicialização são parte do APK-base e não são atualizados pelo próprio PCK. O APK de bootstrap contém o autoload `UpdateManager`, que consulta o manifesto do GitHub Releases, baixa o PCK por HTTPS, confere o SHA-256 e guarda o pacote em `user://updates/pending.pck`.

A cena de inicialização consulta o manifesto antes de abrir o menu. O patch é baixado, conferido por SHA-256 e montado com `ProjectSettings.load_resource_pack(..., true)` antes de carregar a cena do menu principal. Se não houver internet, o jogo segue normalmente. Assim, scripts, cenas, shaders e recursos atualizados podem substituir os arquivos antigos sem reinstalar o APK. Os saves continuam em `user://tobi_breu_save.cfg` e as configurações em `user://tobi_breu_settings.cfg`, fora do pacote de atualização.

## Publicação automática

O workflow `.github/workflows/android-apk.yml` publica o patch quando há um push na branch `integration/definitive-all-versions`. Ele seleciona arquivos de recursos alterados em `scripts/`, `scenes/`, `assets/` e `addons/`, exporta somente esses recursos e suas dependências como PCK e publica `TobiEBreu-update.pck` junto com `update-manifest.json` em um GitHub Release marcado como latest.

O jogo verifica esse manifesto no menu principal. Quando encontra uma versão nova, baixa, valida e monta o pacote automaticamente antes de mostrar o menu. O PCK fica armazenado no diretório privado do app e é montado novamente nas próximas inicializações.

## Limites: quando ainda precisa de APK

Um PCK não substitui o executável Android. Alterações em `project.godot`, permissões Android, identificador do pacote, versão do motor Godot, extensões nativas/GDExtension, bibliotecas Android ou código que precise mudar a configuração de exportação exigem um novo APK. O patch é cumulativo desde o commit-base registrado em `tools/android_update_base_sha.txt`, para que patches posteriores não apaguem alterações de versões anteriores. Exclusões/renomeações de recursos também precisam de tratamento específico; o patch atual é para adicionar/substituir recursos.

A primeira instalação que contém o `UpdateManager` e a cena de inicialização é obrigatória. Um APK já instalado sem esse autoload não consegue receber o atualizador retroativamente.

## Assinatura do APK e preservação do progresso

Para que o Android instale um APK novo por cima do anterior sem desinstalar o app, ambos precisam usar o mesmo certificado de assinatura. O workflow aceita estes GitHub Actions Secrets:

- `ANDROID_KEYSTORE_BASE64`: arquivo keystore codificado em Base64
- `ANDROID_KEYSTORE_PASSWORD`: senha do keystore
- `ANDROID_KEY_ALIAS`: alias da chave
- `ANDROID_KEY_PASSWORD`: senha da chave

Crie uma chave de assinatura privada, codifique o arquivo em Base64 e cadastre os quatro valores em **GitHub → Settings → Secrets and variables → Actions**. Nunca envie o keystore para o repositório público. Sem esses secrets, o workflow usa uma chave temporária apenas para builds de validação; APKs assinados por chaves temporárias diferentes não podem atualizar uns aos outros.

Se o APK atualmente instalado foi assinado por uma chave temporária de uma execução antiga, uma nova chave não será compatível. Nesse caso, a instalação inicial do APK 0.12.2 pode exigir desinstalar a versão antiga, o que apaga os dados privados do aplicativo. Não desinstale antes de exportar/backup do save. Depois que o app com o atualizador estiver instalado com uma assinatura estável, os patches PCK preservam os saves e não exigem reinstalação.

## Verificação

A validação definitiva depende do GitHub Actions: testes Python, importação e inicialização headless do Godot 4.3, exportação Android e execução do teste de emulador. A publicação do PCK só ocorre no fim do workflow quando os passos anteriores terminam com sucesso. Ainda é necessário validar o download e a aplicação em um aparelho Android físico.

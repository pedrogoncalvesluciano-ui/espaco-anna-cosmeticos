# Espaço Anna Cosméticos — versão 2 (protótipo + estrutura administrativa)

## Arquivos
- `index.html`: loja responsiva, catálogo de demonstração, busca, categorias, carrinho e pedido via WhatsApp.
- `admin.html`: painel inicial para login, cadastro, edição e ativação/desativação de produtos usando Supabase.
- `config.js`: configurações públicas da loja.
- `supabase-schema.sql`: tabelas, RLS e políticas de segurança para Supabase.

## Como testar a loja
1. Extraia o ZIP.
2. Abra `index.html` em um navegador. O catálogo de exemplo funciona localmente.
3. Para testar o pedido pelo WhatsApp, edite `config.js` e preencha `whatsappNumber` com DDI + DDD + número, só dígitos. Exemplo de formato: `5544999999999` (substitua pelo número da loja).
4. O checkout abre uma mensagem para confirmação manual. Não cobra nem processa pagamentos.

## Como ativar o catálogo e o painel
1. Crie um projeto no Supabase.
2. No SQL Editor, execute todo o conteúdo de `supabase-schema.sql`.
3. Em `config.js`, preencha `supabaseUrl` e `supabaseAnonKey` com os dados públicos do projeto.
4. Adicione esta linha no `index.html` antes de `config.js` e antes do script principal:
   `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>`
5. Crie um usuário pelo Supabase Auth.
6. Copie o UUID desse usuário e promova-o a administrador no SQL Editor:
   `insert into public.profiles (id, role) values ('UUID-DO-USUARIO', 'admin');`
7. Abra `admin.html`, entre com o e-mail e senha criados e cadastre produtos.
8. Faça um teste com um produto de exemplo antes de colocar o catálogo real no ar.

## Arquitetura recomendada
- Frontend: HTML/CSS/JavaScript responsivo e PWA como próxima etapa.
- Backend gerenciado: Supabase Auth + PostgreSQL + Row Level Security (RLS).
- Atendimento/pedidos iniciais: WhatsApp, com confirmação manual de estoque, frete e pagamento.
- Etapa futura: checkout online com provedor de pagamento e integração de frete. O servidor deve validar preços, estoque e status dos pagamentos.

## Antes de vender de verdade
- Trocar todos os produtos, preços, imagens e descrições fictícios por dados reais dos fornecedores.
- Conferir nota fiscal, procedência, validade, lote, regras de armazenamento e políticas de troca/devolução.
- Definir frete, prazo, atendimento, privacidade/LGPD e termos da loja.
- Configurar domínio e HTTPS.
- Testar o painel e as permissões RLS antes de publicar.
- Nunca colocar service_role key, senha de banco ou segredo de pagamento no frontend.
- O cadastro do fornecedor no painel é para controle interno; não aparece na vitrine.
- A página de pedidos e o checkout com pagamento ainda não estão implementados como fluxo de e-commerce completo. O painel nesta versão gerencia produtos; pedidos recebidos via WhatsApp devem ser confirmados manualmente.

Este pacote é um starter de desenvolvimento, não uma loja pronta para receber pagamentos automaticamente.

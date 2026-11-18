# UX-CONTRACT — Lunae Pulse

## Escopo e fontes

Pedido do usuário: criar somente o frontend em Flutter. Fonte de telas: Lunae_Pulse_Design_System_e_Telas.md (16/11/2026), T01–T53. O documento orienta o produto, não autoriza backend. IA e B2B são demonstrações futuras. Não há política legal final, cobrança, permissões reais ou ciclo de conta nesta entrega.

## Canonical UI Map

| Capability | Canonical owner | Source of truth | Allowed variants | Verification |
|---|---|---|---|---|
| Select/Listbox | Material DropdownButtonFormField | DESIGN.md / ColorScheme | native Flutter overlay | testes de layout e navegação |
| Form | Form / TextFormField / GlobalKey | validadores de cada domínio | cadastro e registro | widget_test.dart |
| Toast | feedback em core/widgets.dart | SnackBar / ScaffoldMessenger | sucesso e desfazer | teste de água com desfazer |
| CRUD | PulseStore e Navigator | estado desta sessão | registros demonstrativos | refeição, peso e série |
| Scrollbar | ScrollBehavior do Material | ThemeData | comportamento nativo Flutter | layouts de 320, 390 e 1280 dp |

Date: não há calendário externo, datas são exemplos identificados; sem seletor de data nesta entrega. Table Selection: não aplicável, sem tabelas selecionáveis. Busca local não persiste consulta sensível em URL.

## Navegação e estado

Cinco abas preservadas por IndexedStack; rotas de detalhe por Navigator. Catálogo de 53 telas acessível no ícone de grade. Voltar preserva o estado em memória. Dados são explicitamente descartados ao encerrar o app; não há alegação de persistência em disco ou sincronização real.

## Fluxos

| Operação | Sucesso | Erro | Recuperação |
|---|---|---|---|
| Registrar água | painel atual + confirmação | quantidade fora do intervalo | editar entrada; desfazer adição |
| Registrar alimento | retorno ao catálogo + confirmação | porção inválida | correção no campo |
| Remover alimento | diário atualizado | não aplicável em memória | desfazer |
| Registrar peso | permanece no registro + gráfico atualizado | valor inválido | erro junto do campo |
| Registrar série | contador compartilhado + descanso | carga/repetição inválida | correção no campo |
| Encerrar treino | resumo + histórico em memória | não aplicável em memória | confirmação antes de encerrar |
| Limpar sessão | remove registros locais | não aplicável | diálogo com escopo e cancelar em foco |

## Privacidade e integrações

Auth, e-mail, câmera, GPS, dispositivos, IA e relatórios são explicitamente simulações visuais. Nenhuma chamada de rede do produto; nenhuma credencial persistida. Integrações não simulam sucesso real. Política definitiva deve ser fornecida antes da integração.

## Localização e acessibilidade

Locale pt-BR e delegates Material. Decimal com vírgula; unidades explícitas. Ícones interativos com tooltip, campos com label persistente, Form com erros próximos. Layouts roláveis com SafeArea, escalonamento de texto e foco Material. Gráficos têm resumo semântico e identificação da faixa para evitar leitura enganosa.

## Verificação

Flutter analyze, flutter test e build web. Matriz automatizada: todas as 53 telas em claro 390 dp, escuro 320 dp com escala 1,3 e desktop 1280 dp. A auditoria estática premium não substitui execução Flutter. Navegador e dispositivos físicos são validações adicionais e devem ser reportados conforme realmente executados.

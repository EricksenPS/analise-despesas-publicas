# 📊 Análise de Despesas Públicas Federais — Portal da Transparência

🇬🇧 *[Read this README in English](README.en.md)*

## 📌 Sobre o projeto

Este projeto consiste em uma análise exploratória das despesas públicas do Governo Federal brasileiro, utilizando dados abertos do **Portal da Transparência**. O objetivo foi praticar um pipeline completo de análise de dados — da extração e tratamento (ETL) até a geração de insights de negócio — usando **SQL Server** como ferramenta principal.

O projeto cobre os meses de **maio, junho e julho de 2026**.

![Dashboard Power BI](power%20bi/dashboard_preview.png)

## 🗂️ Fonte dos dados

- **Origem:** [Portal da Transparência do Governo Federal](https://portaldatransparencia.gov.br/download-de-dados)
- **Categoria:** Despesas Públicas → Execução da despesa
- **Formato original:** CSV (delimitado por `;`, qualificador de texto `"`, encoding UTF-8)
- **Volume:** 148.832 lançamentos, somando os 3 meses

## 🛠️ Ferramentas utilizadas

- **SQL Server / SSMS** — armazenamento, tratamento e análise dos dados
- **Excel** — inspeção inicial dos arquivos brutos
- *(Em andamento)* **Power BI** — construção de dashboard interativo

## ⚙️ Processo de ETL (Extração, Tratamento e Carga)

1. **Extração:** download manual dos arquivos CSV mensais diretamente do Portal da Transparência
2. **Carga:** importação via ferramenta *Import Flat File* do SSMS, gerando uma tabela "bruta" (raw) por mês, com as 47 colunas originais
3. **Tratamento:** entre os principais desafios resolvidos:
   - Ajuste de tipos de coluna (`nvarchar(50)` → `nvarchar(255)`) para evitar truncamento em campos de texto longos (nomes de programas, ações orçamentárias)
   - Permissão de valores nulos em colunas que continham células vazias no CSV original
   - Identificação correta de delimitador (`;`) e qualificador de texto (`"`) do arquivo de origem
4. **Consolidação:** unificação das 3 tabelas mensais brutas em uma única tabela limpa e enxuta (`despesas_publicas`), com apenas as colunas relevantes para análise, via `INSERT INTO ... UNION ALL`

## 🗃️ Modelo de dados final

**Tabela: `despesas_publicas`**

| Coluna | Descrição |
|---|---|
| AnoMes | Ano e mês de referência do lançamento |
| NomeOrgaoSuperior | Ministério/órgão superior |
| NomeOrgao | Órgão ou unidade gestora específica |
| NomeFuncao | Função de governo (Educação, Saúde, Defesa, etc.) |
| NomeSubfuncao | Subfunção orçamentária |
| NomePrograma | Programa orçamentário |
| NomeAcao | Ação orçamentária |
| UF | Estado de destino do recurso (pode ser nulo) |
| NomeLocal | Município de destino do recurso |
| ValorEmpenhado | Valor empenhado no período |
| ValorLiquidado | Valor liquidado no período |
| ValorPago | Valor efetivamente pago no período |

## ❓ Perguntas de negócio respondidas

**1. Quais órgãos superiores têm maior execução orçamentária?**
O Ministério da Fazenda lidera em valor total (R$ 49,1 bi empenhados), mas com poucos lançamentos (1.909) — sugerindo poucos lançamentos de valor muito alto. Já o Ministério da Educação tem o maior número de lançamentos (43.146), refletindo sua rede pulverizada de universidades e institutos federais.

**2. Como os gastos evoluem entre os 3 meses analisados?**
Julho apresenta o menor valor empenhado, mas o maior valor pago — reflexo de os dados terem sido coletados no início do mês (execução do mês ainda parcial).

**3. Qual o percentual do valor empenhado que efetivamente foi pago?**
Alguns órgãos apresentam taxas acima de 100%, pois o valor pago no período inclui a quitação de *Restos a Pagar* de exercícios anteriores — uma limitação importante da janela temporal de 3 meses (ver seção de limitações).

**4. Existe algum órgão com valor pago maior que o empenhado?**
Sim, 197 combinações de órgão apresentam esse padrão, incluindo casos extremos como valor empenhado negativo (estornos) — por exemplo, a Polícia Rodoviária Federal, com empenho líquido de -R$ 68,2 bi no período.

**5. Quais funções de governo recebem mais recursos?**
"Encargos Especiais" lidera disparado (R$ 53,7 tri), mas é uma categoria financeira/contábil (dívida pública, transferências constitucionais), não uma política pública específica. Excluindo essa categoria, **Previdência Social** (R$ 16,6 tri) lidera, seguida de Saúde (R$ 5,1 tri).

**6. Dentro de uma função específica, quais programas recebem mais recursos?**
Em Saúde, os programas de Atenção Especializada e Atenção Primária concentram a maior parte dos recursos, somando mais de R$ 4 trilhões.

**7. Quais estados (UF) recebem mais recursos federais?**
Distrito Federal lidera, seguido de SP, MG, RJ e RS — refletindo a concentração de órgãos administrativos centrais em Brasília.

**8. Qual a proporção de gastos sem UF associada?**
**94,09%** do valor total empenhado não possui UF associada — a análise geográfica (pergunta 7) representa apenas uma fração pequena (~6%) do orçamento total, majoritariamente composta por despesas de natureza nacional/administrativa central.

**9. Qual órgão gasta mais especificamente dentro de uma função (ex: Educação)?**
O Fundo Nacional de Desenvolvimento da Educação (FNDE) lidera com folga (R$ 311,8 bi), seguido de instituições de ensino superior federais.

## ⚠️ Limitações identificadas

- **Janela temporal curta (3 meses):** métricas de "execução orçamentária" (% pago vs. empenhado) podem ultrapassar 100% ou ser negativas, pois valores pagos/estornados no período podem se referir a compromissos assumidos em exercícios anteriores, fora da janela analisada.
- **Concentração geográfica aparente:** 94% do orçamento não tem UF associada, o que limita fortemente qualquer análise por distribuição geográfica.
- **Julho parcial:** os dados desse mês foram coletados no início do período, então a execução orçamentária de julho está subestimada em relação a maio e junho.

## 📊 Próximos passos

- Construção de dashboard interativo no **Power BI**, com medidas DAX para as métricas já validadas em SQL
- Estudo de *window functions* (`ROW_NUMBER()`, `PARTITION BY`) para generalizar a pergunta 9 (top órgão por função, para todas as funções simultaneamente)
- Ampliação da janela temporal (incorporar mais meses) para reduzir as distorções identificadas nas limitações

## 📁 Estrutura do repositório

```
projeto-despesas-publicas/
├── README.md                    <- este arquivo
├── README.en.md                 <- versão em inglês
├── sql/
│   ├── 01_setup_e_importacao.sql
│   └── 02_queries_analise.sql
└── powerbi/                     <- (em breve)
```

---

*Projeto desenvolvido como parte de um portfólio de análise de dados, aplicando SQL Server sobre dados públicos reais.*

/* ============================================================
   PROJETO: Análise de Despesas Públicas Federais
   ARQUIVO: 01_setup_e_importacao.sql
   DESCRIÇÃO: Criação do banco, tabela final e consolidação
               dos dados dos 3 meses (maio, junho, julho/2026)
   FONTE: Portal da Transparência (portaldatransparencia.gov.br)
   ============================================================ */


-- ============================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- ============================================================

CREATE DATABASE despesas_governo;
GO

USE despesas_governo;
GO


-- ============================================================
-- 2. CRIAÇÃO DA TABELA FINAL (enxuta, só com colunas de análise)
-- ============================================================

CREATE TABLE despesas_publicas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AnoMes VARCHAR(7) NOT NULL,              -- ex: '2026/07'
    NomeOrgaoSuperior VARCHAR(300),
    NomeOrgao VARCHAR(300),
    NomeFuncao VARCHAR(300),
    NomeSubfuncao VARCHAR(300),
    NomePrograma VARCHAR(300),
    NomeAcao VARCHAR(500),
    UF VARCHAR(2),
    NomeLocal VARCHAR(300),
    ValorEmpenhado DECIMAL(18,2),
    ValorLiquidado DECIMAL(18,2),
    ValorPago DECIMAL(18,2)
);
GO


-- ============================================================
-- 3. IMPORTAÇÃO DOS DADOS BRUTOS (RAW)
-- ============================================================
-- Os 3 arquivos CSV (202605_Despesas.csv, 202606_Despesas.csv,
-- 202607_Despesas.csv) foram importados individualmente usando
-- a ferramenta gráfica do SSMS:
--
--   Botão direito no banco > Tarefas > Importar Arquivo Simples
--
-- Configurações usadas em cada importação:
--   - Code page: 65001 (UTF-8)
--   - Formato: Delimitado
--   - Delimitador de coluna: ; (ponto e vírgula)
--   - Qualificador de texto: " (aspas duplas)
--   - "Permitir Nulos": marcado em todas as colunas
--   - Colunas de texto longas ajustadas de nvarchar(50)
--     para nvarchar(255) (ex: Nome_Ação, Nome_Autor_Emenda,
--     Nome_Programa_Orçamentário, Plano_Orçamentário)
--
-- Tabelas resultantes:
--   despesas_publicas_raw_maio    (67.387 linhas)
--   despesas_publicas_raw_junho   (64.728 linhas)
--   despesas_publicas_raw_julho   (16.717 linhas)
--
-- Caso precise renomear uma tabela após a importação:
-- EXEC sp_rename 'despesas_publicas_raw', 'despesas_publicas_raw_julho';


-- ============================================================
-- 4. CONSOLIDAÇÃO DOS 3 MESES NA TABELA FINAL
-- ============================================================

INSERT INTO despesas_publicas (
    AnoMes,
    NomeOrgaoSuperior,
    NomeOrgao,
    NomeFuncao,
    NomeSubfuncao,
    NomePrograma,
    NomeAcao,
    UF,
    NomeLocal,
    ValorEmpenhado,
    ValorLiquidado,
    ValorPago
)
SELECT Ano_e_mês_do_lançamento, Nome_Órgão_Superior, Nome_Órgão_Subordinado,
       Nome_Função, Nome_Subfunção, Nome_Programa_Orçamentário, Nome_Ação,
       UF, Município, Valor_Empenhado_R, Valor_Liquidado_R, Valor_Pago_R
FROM despesas_publicas_raw_maio

UNION ALL

SELECT Ano_e_mês_do_lançamento, Nome_Órgão_Superior, Nome_Órgão_Subordinado,
       Nome_Função, Nome_Subfunção, Nome_Programa_Orçamentário, Nome_Ação,
       UF, Município, Valor_Empenhado_R, Valor_Liquidado_R, Valor_Pago_R
FROM despesas_publicas_raw_junho

UNION ALL

SELECT Ano_e_mês_do_lançamento, Nome_Órgão_Superior, Nome_Órgão_Subordinado,
       Nome_Função, Nome_Subfunção, Nome_Programa_Orçamentário, Nome_Ação,
       UF, Município, Valor_Empenhado_R, Valor_Liquidado_R, Valor_Pago_R
FROM despesas_publicas_raw_julho;
GO


-- ============================================================
-- 5. VERIFICAÇÃO FINAL
-- ============================================================

SELECT COUNT(*) AS Total_Linhas_Consolidadas
FROM despesas_publicas;
-- Resultado esperado: 148.832

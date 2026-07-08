/* ============================================================
   PROJETO: Análise de Despesas Públicas Federais
   ARQUIVO: 02_queries_analise.sql
   DESCRIÇÃO: 9 perguntas de negócio respondidas com SQL
   BASE: despesas_publicas (148.832 linhas, mai-jul/2026)
   ============================================================ */

USE despesas_governo;
GO


-- ============================================================
-- 1. Quais órgãos superiores têm maior execução orçamentária?
-- ============================================================

SELECT 
    NomeOrgaoSuperior,
    COUNT(*) AS QtdeLancamentos,
    SUM(ValorEmpenhado) AS TotalEmpenhado,
    SUM(ValorLiquidado) AS TotalLiquidado,
    SUM(ValorPago) AS TotalPago
FROM despesas_publicas
GROUP BY NomeOrgaoSuperior
ORDER BY TotalEmpenhado DESC;


-- ============================================================
-- 2. Como os gastos evoluem entre os 3 meses analisados?
-- ============================================================

SELECT 
    AnoMes,
    SUM(ValorEmpenhado) AS TotalEmpenhado,
    SUM(ValorLiquidado) AS TotalLiquidado,
    SUM(ValorPago) AS TotalPago
FROM despesas_publicas
GROUP BY AnoMes
ORDER BY AnoMes ASC;


-- ============================================================
-- 3. Qual o percentual do valor empenhado que foi pago?
--    (taxa de execução, por órgão)
-- ============================================================

SELECT
    NomeOrgaoSuperior,
    NomeOrgao,
    (SUM(ValorPago) / NULLIF(SUM(ValorEmpenhado), 0)) * 100 AS Percentual_Pago
FROM despesas_publicas
GROUP BY NomeOrgaoSuperior, NomeOrgao
ORDER BY Percentual_Pago DESC;


-- ============================================================
-- 4. Existe algum órgão com valor pago maior que o empenhado?
-- ============================================================

SELECT
    NomeOrgaoSuperior,
    NomeOrgao,
    SUM(ValorPago) AS Total_Pago,
    SUM(ValorEmpenhado) AS Total_Empenhado
FROM despesas_publicas
GROUP BY NomeOrgaoSuperior, NomeOrgao
HAVING SUM(ValorPago) > SUM(ValorEmpenhado)
ORDER BY Total_Empenhado ASC;


-- ============================================================
-- 5. Quais funções de governo recebem mais recursos?
--    (excluindo "Encargos especiais", categoria financeira
--    atípica que distorce a comparação entre políticas públicas)
-- ============================================================

SELECT NomeFuncao, SUM(ValorEmpenhado) AS Total_Empenhado
FROM despesas_publicas
WHERE NomeFuncao <> 'Encargos Especiais'
GROUP BY NomeFuncao
ORDER BY Total_Empenhado DESC;


-- ============================================================
-- 6. Dentro de uma função específica, quais programas recebem
--    mais recursos? (exemplo: Saúde)
-- ============================================================

SELECT NomeFuncao, NomePrograma, SUM(ValorEmpenhado) AS Valor_Empenhado
FROM despesas_publicas
WHERE NomeFuncao = 'Saúde'
GROUP BY NomeFuncao, NomePrograma
ORDER BY Valor_Empenhado DESC;


-- ============================================================
-- 7. Quais estados (UF) recebem mais recursos federais?
-- ============================================================

SELECT UF, SUM(ValorEmpenhado) AS Total_Empenhado
FROM despesas_publicas
WHERE UF IS NOT NULL
GROUP BY UF
ORDER BY Total_Empenhado DESC;


-- ============================================================
-- 8. Qual a proporção do orçamento sem UF associada?
-- ============================================================

SELECT
    SUM(ValorEmpenhado) AS Total_Geral,
    SUM(CASE WHEN UF IS NULL THEN ValorEmpenhado ELSE 0 END) AS Total_Sem_UF,
    (NULLIF(SUM(CASE WHEN UF IS NULL THEN ValorEmpenhado ELSE 0 END), 0)
        / SUM(ValorEmpenhado)) * 100 AS Percentual_Sem_UF
FROM despesas_publicas;
-- Resultado: 94,09% do orçamento não possui UF associada


-- ============================================================
-- 9. Qual órgão gasta mais especificamente dentro de uma função?
--    (exemplo: Educação, top 10)
-- ============================================================

SELECT TOP 10 NomeOrgao, NomeFuncao, SUM(ValorEmpenhado) AS Total_Empenhado
FROM despesas_publicas
WHERE NomeFuncao = 'Educação'
GROUP BY NomeFuncao, NomeOrgao
ORDER BY Total_Empenhado DESC;

/* NOTA: esta query está fixa para a função 'Educação'. Uma
   versão generalizada (top órgão para CADA função ao mesmo
   tempo) exigiria window functions, como ROW_NUMBER() OVER
   (PARTITION BY NomeFuncao ORDER BY ...) — próximo tópico de
   estudo planejado para evolução deste projeto. */

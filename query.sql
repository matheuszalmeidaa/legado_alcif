-- ============================================================
-- View: qlik_legado_c6
-- Fonte: csd.workbank.proposta (tem id_proposta, dat_crc,
-- nome_produto, qtd_parcelas e id_banco nativamente, com os tipos
-- corretos).
--
-- Filtro:
--   - banco = C6 (id_banco = 129)
--   - qtd_parcelas apenas 84, 96 ou 108
--   - exclui propostas que já pertencem ao legado a partir de
--     2025-01-01 (id_proposta presente em dfs.lais.legado_filtro
--     com dat_crc >= 2025-01-01), para não duplicar com a view
--     dfs.work.qlik_legado_NOVO.
--
-- dat_crc é TEXT em csd.workbank.proposta, no formato
-- 'DD/MM/YYYY HH:MM:SS' (ex.: '30/06/2026 00:00:00'), e DATE em
-- dfs.lais.legado_filtro. Por isso o parse abaixo usa TO_DATE com
-- máscara explícita 'dd/MM/yyyy HH:mm:ss'.
--
-- Colunas:
--   proposta = id_proposta
--   mes      = dat_crc, formatado como MM/YYYY
--   tabela   = nome_produto
--   prazo    = qtd_parcelas
--   banco    = id_banco
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    p.id_proposta                                                    AS proposta,
    TO_CHAR(TO_DATE(p.dat_crc, 'dd/MM/yyyy HH:mm:ss'), 'MM/YYYY')    AS mes,
    p.nome_produto                                                   AS tabela,
    p.qtd_parcelas                                                   AS prazo,
    p.id_banco                                                       AS banco
FROM csd.workbank.proposta AS p
WHERE p.id_banco = 129
    AND p.qtd_parcelas IN (84, 96, 108)
    AND NOT EXISTS (
        SELECT 1
        FROM dfs.lais.legado_filtro AS lf
        WHERE lf.id_proposta = p.id_proposta
            AND lf.dat_crc >= '2025-01-01'
    );

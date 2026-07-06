-- ============================================================
-- View: qlik_legado_c6
-- Fonte: csd.workbank.proposta (tem id_proposta, dat_crc,
-- nome_produto, qtd_parcelas e id_banco nativamente, com os tipos
-- corretos).
--
-- Filtro:
--   - banco = C6 (id_banco = 129)
--   - dat_crc a partir de 2025-01-01
--   - exclui propostas que já pertencem ao legado (id_proposta
--     presente em dfs.lais.legado_filtro), para não duplicar com
--     a view dfs.work.qlik_legado_NOVO.
--
-- dat_crc é TEXT em csd.workbank.proposta. O filtro de data abaixo
-- assume que os valores estão em formato ISO 'YYYY-MM-DD' (comparação
-- de texto funciona como comparação de data nesse formato). Se o
-- formato for outro, me avise para eu ajustar.
--
-- Filtra também qtd_parcelas apenas para os prazos 84, 96 ou 108.
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
    p.id_proposta                                  AS proposta,
    TO_CHAR(CAST(p.dat_crc AS DATE), 'MM/YYYY')    AS mes,
    p.nome_produto                                 AS tabela,
    p.qtd_parcelas                                 AS prazo,
    p.id_banco                                     AS banco
FROM csd.workbank.proposta AS p
WHERE p.id_banco = 129
    AND p.dat_crc >= '2025-01-01'
    AND p.qtd_parcelas IN (84, 96, 108)
    AND NOT EXISTS (
        SELECT 1
        FROM dfs.lais.legado_filtro AS lf
        WHERE lf.id_proposta = p.id_proposta
    );

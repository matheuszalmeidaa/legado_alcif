-- ============================================================
-- View: qlik_legado_c6
-- Fonte: csd.workbank.proposta (tem id_proposta, dat_crc,
-- nome_produto, qtd_parcelas e id_banco nativamente, com os tipos
-- corretos).
--
-- Filtro:
--   - banco = C6 (id_banco = 129)
--   - exclui propostas que já pertencem ao legado (id_proposta
--     presente em dfs.lais.legado_filtro), para não duplicar com
--     a view dfs.work.qlik_legado_NOVO.
--
-- Colunas:
--   proposta = id_proposta
--   mes      = dat_crc
--   tabela   = nome_produto
--   prazo    = qtd_parcelas
--   banco    = id_banco
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    p.id_proposta   AS proposta,
    p.dat_crc       AS mes,
    p.nome_produto  AS tabela,
    p.qtd_parcelas  AS prazo,
    p.id_banco      AS banco
FROM csd.workbank.proposta AS p
WHERE p.id_banco = 129
    AND NOT EXISTS (
        SELECT 1
        FROM dfs.lais.legado_filtro AS lf
        WHERE lf.id_proposta = p.id_proposta
    );

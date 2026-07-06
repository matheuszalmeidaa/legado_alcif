-- ============================================================
-- View: qlik_legado_c6
-- Recorte do legado somente para o banco C6 (id_banco = 129),
-- lendo direto da tabela base (não depende/altera a view
-- dfs.work.qlik_legado_NOVO já existente).
--
-- Colunas:
--   proposta = id_proposta
--   mes      = dat_crc
--   tabela   = nome_produto
--   prazo    = qtd_parcelas
--
-- Mantém os mesmos filtros de validade usados na qlik_legado_NOVO
-- (propostas a partir de 2023, não excluídas).
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    p.id_proposta   AS proposta,
    p.dat_crc       AS mes,
    p.nome_produto  AS tabela,
    p.qtd_parcelas  AS prazo
FROM dfs.lais.legado_filtro AS p
WHERE p.id_banco = 129
    AND EXTRACT(YEAR FROM p.dat_crc) >= 2023
    AND p.id_proposta IS NOT NULL
    AND p.proposta_bessa IS NULL
    AND p.propostas_excluir IS NULL;

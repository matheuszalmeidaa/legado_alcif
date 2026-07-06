-- ============================================================
-- View: qlik_legado_c6
-- Banco C6 (id_banco = 129), unindo:
--   - histórico completo: dfs.lais.legado_filtro
--   - atual: csd.workbank.proposta, excluindo o que já está no
--     legado a partir de 2025-01-01 (evita duplicar)
--
-- Colunas:
--   proposta = id_proposta
--   mes      = dat_crc, formatado como MM/YYYY
--   tabela   = nome_produto
--   prazo    = qtd_parcelas
--   banco    = id_banco
--
-- Observações:
--   - dfs.lais.legado_filtro não tem coluna de parcelas (qtd_parcelas
--     ou equivalente), então prazo sai NULL no lado histórico, e não
--     dá pra aplicar o filtro de prazo (84/96/108) nesse lado.
--   - dat_crc é DATE em dfs.lais.legado_filtro e TEXT em
--     csd.workbank.proposta, no formato 'DD/MM/YYYY HH:MM:SS'
--     (ex.: '30/06/2026 00:00:00'), por isso o parse com TO_DATE e
--     máscara explícita só no lado de proposta.
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    lf.id_proposta                  AS proposta,
    TO_CHAR(lf.dat_crc, 'MM/YYYY')  AS mes,
    lf.nome_produto                 AS tabela,
    CAST(NULL AS INTEGER)           AS prazo,
    lf.id_banco                     AS banco
FROM dfs.lais.legado_filtro AS lf
WHERE lf.id_banco = 129

UNION ALL

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
        FROM dfs.lais.legado_filtro AS lf2
        WHERE lf2.id_proposta = p.id_proposta
            AND lf2.dat_crc >= DATE '2025-01-01'
    );

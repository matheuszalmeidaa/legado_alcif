-- ============================================================
-- View: qlik_legado_c6
-- Banco C6 (id_banco = 129), unindo:
--   - histórico completo: csd.python.qlik
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
--   - csd.python.qlik guarda tudo como TEXT (inclusive id_proposta,
--     id_banco e qtd_parcelas), por isso os CASTs abaixo.
--   - id_banco em csd.python.qlik é o ID numérico como string
--     (ex.: '129'), não o nome do banco.
--   - dat_crc em csd.python.qlik é TEXT. Estou assumindo o mesmo
--     formato confirmado em csd.workbank.proposta
--     ('DD/MM/YYYY HH:MM:SS', ex.: '30/06/2026 00:00:00'). Se um
--     valor de exemplo de csd.python.qlik.dat_crc vier diferente
--     disso, me avise para eu ajustar a máscara do TO_DATE.
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    CAST(lf.id_proposta AS INTEGER)                                    AS proposta,
    TO_CHAR(TO_DATE(lf.dat_crc, 'dd/MM/yyyy HH:mm:ss'), 'MM/YYYY')     AS mes,
    lf.nome_produto                                                    AS tabela,
    CAST(lf.qtd_parcelas AS INTEGER)                                   AS prazo,
    CAST(lf.id_banco AS INTEGER)                                       AS banco
FROM csd.python.qlik AS lf
WHERE CAST(lf.id_banco AS INTEGER) = 129
    AND CAST(lf.qtd_parcelas AS INTEGER) IN (84, 96, 108)

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
        FROM csd.python.qlik AS lf2
        WHERE CAST(lf2.id_proposta AS INTEGER) = p.id_proposta
            AND TO_DATE(lf2.dat_crc, 'dd/MM/yyyy HH:mm:ss') >= DATE '2025-01-01'
    );

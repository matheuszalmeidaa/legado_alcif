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
--   - dat_crc em csd.python.qlik é TEXT no formato ISO 'yyyy-MM-dd'
--     (ex.: '2021-07-19'), diferente de csd.workbank.proposta (que é
--     'dd/MM/yyyy HH:mm:ss'). Por isso cada lado usa sua própria
--     máscara no TO_DATE.
--   - csd.python.qlik tem lixo textual em campos vazios/errados
--     (ex.: '*NÃO PREENCHIDO*', 'NULL' como string literal), o que
--     quebra o CAST AS INTEGER. Em vez de excluir string por string,
--     o filtro abaixo só aceita valores puramente numéricos
--     (SIMILAR TO '[0-9]+') antes de castar.
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    CAST(lf.id_proposta AS INTEGER)                                    AS proposta,
    TO_CHAR(TO_DATE(lf.dat_crc, 'yyyy-MM-dd'), 'MM/YYYY')              AS mes,
    lf.nome_produto                                                    AS tabela,
    CAST(lf.qtd_parcelas AS INTEGER)                                   AS prazo,
    CAST(lf.id_banco AS INTEGER)                                       AS banco
FROM csd.python.qlik AS lf
WHERE lf.id_proposta SIMILAR TO '[0-9]+'
    AND lf.id_banco SIMILAR TO '[0-9]+'
    AND lf.qtd_parcelas SIMILAR TO '[0-9]+'
    AND CAST(lf.id_banco AS INTEGER) = 129
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
        WHERE lf2.id_proposta SIMILAR TO '[0-9]+'
            AND CAST(lf2.id_proposta AS INTEGER) = p.id_proposta
            AND TO_DATE(lf2.dat_crc, 'yyyy-MM-dd') >= DATE '2025-01-01'
    );

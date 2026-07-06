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
--     (ex.: '*NÃO PREENCHIDO*', 'NULL' como string literal). Além
--     disso, por vir de exportação Python, números às vezes chegam
--     como '129.0'/'84.0' (float stringificado) ou com espaços em
--     branco em volta. Por isso: (1) usa-se TRIM antes de validar,
--     (2) o padrão aceita um '.0' opcional, e (3) o CAST vai para
--     FLOAT antes de virar INTEGER (CAST direto de '129.0' para
--     INTEGER falha).
--   - dat_crc recebe proteção parecida, mas comparando só os 10
--     primeiros caracteres (SUBSTR(dat_crc, 1, 10)) contra o padrão
--     'yyyy-MM-dd'. Isso evita rejeitar linhas cujo dat_crc venha
--     com horário junto (ex.: '2021-07-19 00:00:00'), que um SIMILAR
--     TO exato excluiria indevidamente.
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    CAST(CAST(TRIM(lf.id_proposta) AS FLOAT) AS INTEGER)                     AS proposta,
    TO_CHAR(TO_DATE(SUBSTR(lf.dat_crc, 1, 10), 'yyyy-MM-dd'), 'MM/YYYY')    AS mes,
    lf.nome_produto                                                          AS tabela,
    CAST(CAST(TRIM(lf.qtd_parcelas) AS FLOAT) AS INTEGER)                    AS prazo,
    CAST(CAST(TRIM(lf.id_banco) AS FLOAT) AS INTEGER)                        AS banco
FROM csd.python.qlik AS lf
WHERE TRIM(lf.id_proposta) SIMILAR TO '[0-9]+(\.[0-9]+)?'
    AND TRIM(lf.id_banco) SIMILAR TO '[0-9]+(\.[0-9]+)?'
    AND TRIM(lf.qtd_parcelas) SIMILAR TO '[0-9]+(\.[0-9]+)?'
    AND SUBSTR(lf.dat_crc, 1, 10) SIMILAR TO '[0-9]{4}-[0-9]{2}-[0-9]{2}'
    AND CAST(CAST(TRIM(lf.id_banco) AS FLOAT) AS INTEGER) = 129
    AND CAST(CAST(TRIM(lf.qtd_parcelas) AS FLOAT) AS INTEGER) IN (84, 96, 108)

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
        WHERE TRIM(lf2.id_proposta) SIMILAR TO '[0-9]+(\.[0-9]+)?'
            AND SUBSTR(lf2.dat_crc, 1, 10) SIMILAR TO '[0-9]{4}-[0-9]{2}-[0-9]{2}'
            AND CAST(CAST(TRIM(lf2.id_proposta) AS FLOAT) AS INTEGER) = p.id_proposta
            AND TO_DATE(SUBSTR(lf2.dat_crc, 1, 10), 'yyyy-MM-dd') >= DATE '2025-01-01'
    );

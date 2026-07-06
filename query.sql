-- ============================================================
-- View 1: qlik_legado_NOVO
-- Base histórica (tudo que já passou), com filtro de propostas
-- válidas a partir de 2023.
-- Expõe id_banco e qtd_parcelas (sem alias) além das colunas de
-- apresentação, para servir de fonte para a view de consolidação
-- (qlik_legado_NOVO + qlik_tmp) mais abaixo.
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_NOVO AS
SELECT
    p.numero_contrato AS `Número Contrato`,
    p.numero_proposta AS `Número Proposta`,
    p.id_proposta AS `ID Proposta`,
    p.vlr_repasse AS `Produção`,
    p.vlr_liquido AS `Líquido`,
    p.vlr_bruto AS `Bruto`,
    b.nome_banco AS `Nome Banco`,
    p.nome_produto AS `Nome Produto`,
    h.id_agente AS `ID Parceiro`,
    h.nome_agente AS `Nome Parceiro`,
    h.id_supervisor AS `ID Supervisor`,
    h.nome_supervisor AS `Nome Supervisor`,
    h.id_gerente_regional,
    h.nome_gerente_regional AS `Nome Regional`,
    h.id_superintendente,
    h.nome_superintendente AS `Nome Superintendente`,
    p.nome_situacao_proposta AS `Nome Situação Proposta`,
    p.nome_unidade_empresa AS `Nome Unidade Parceiro`,
    a.situacao AS `Situação Parceiro`,
    p.dat_operacao AS `Data Digitação`,
    p.dat_crc AS `Data Liberação Crédito`,
    p.grupo_produto AS `Convênio`,
    a.status_cadastro AS `Status Parceiros`,
    p.proposta_bessa,
    p.propostas_excluir,
    p.id_banco,
    p.qtd_parcelas,
    0 AS `Valor Seguro`,
    '-' AS `CPF Cliente`
FROM dfs.lais.legado_filtro AS p
LEFT JOIN dfs.com.banco AS b
    ON b.id_banco = CAST(p.id_banco AS VARCHAR)
LEFT JOIN dfs.work.hierarquia_agente AS h
    ON h.id_agente = p.id_parceiro
LEFT JOIN csd.workbank.agente AS a
    ON a.id_parceiro = h.id_agente
WHERE EXTRACT(YEAR FROM p.dat_crc) >= 2023
    AND p.id_proposta IS NOT NULL
    AND p.proposta_bessa IS NULL
    AND p.propostas_excluir IS NULL;

-- ============================================================
-- View 2: qlik_legado_c6
-- Recorte do histórico (qlik_legado_NOVO) somente para o banco
-- C6 (id_banco = 129), com as colunas renomeadas:
--   proposta = id_proposta
--   mes      = dat_crc
--   tabela   = nome_produto
--   prazo    = qtd_parcelas
-- ============================================================
CREATE OR REPLACE VIEW dfs.work.qlik_legado_c6 AS
SELECT
    l.`ID Proposta`                 AS proposta,
    l.`Data Liberação Crédito`      AS mes,
    l.`Nome Produto`                AS tabela,
    l.qtd_parcelas                  AS prazo
FROM dfs.work.qlik_legado_NOVO AS l
WHERE l.id_banco = 129;

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
    0 AS `Valor Seguro`,
    '-' AS `CPF Cliente`
FROM dfs.work.qlik_tmp_legado AS p
LEFT JOIN csd.workbank.banco AS b
    ON b.id_banco = p.id_banco
LEFT JOIN dfs.work.hierarquia_agente AS h
    ON h.id_agente = p.id_parceiro
LEFT JOIN csd.workbank.agente AS a
    ON a.id_parceiro = h.id_agente;

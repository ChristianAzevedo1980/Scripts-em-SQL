drop table if exists sandbox_dee.christiana_estrutura_mensal_GIA;
 
-- INSERT INTO sandbox_dee.christiana_estrutura_mensal_GIA (
 -- anomes,
 -- valor_difusores,
 -- valor_total,
-- qtd_difusores,
-- qtd_total,
 -- perc_valor_difusores
-- perc_qtd_difusores
-- )
 
SELECT
    -- Ano da emissão (chave temporal)
    TO_CHAR(gia_capa.dt_apuracao, 'YYYYMM') AS anomes,
 
    -- Valor apenas dos CNAEs difusores (25 a 30)
     SUM(
      CASE
        WHEN (gia_capa.cod_cnae_grupo LIKE '25%'
           OR gia_capa.cod_cnae_grupo LIKE '26%'
           OR gia_capa.cod_cnae_grupo LIKE '27%'
           OR gia_capa.cod_cnae_grupo LIKE '28%'
           OR gia_capa.cod_cnae_grupo LIKE '29%'
           OR gia_capa.cod_cnae_grupo LIKE '30%')
           AND deecfop.ind_atividade_economica = 'S'
        THEN COALESCE(a5.vlr_contabil, 0)
       ELSE 0
     END
     ) AS valor_difusores,
 
    -- Valor total de todos os CNAEs
    SUM(COALESCE(a5.vlr_contabil, 0)) AS valor_total,
 
        -- Participação percentual em VALOR dos difusores no total
     CASE
       WHEN SUM(COALESCE(a5.vlr_contabil, 0)) = 0 THEN 0
       ELSE ROUND(
         (
           SUM(
            CASE
              WHEN (gia_capa.cod_cnae_grupo LIKE '25%'
                   OR gia_capa.cod_cnae_grupo LIKE '26%'
                   OR gia_capa.cod_cnae_grupo LIKE '27%'
                   OR gia_capa.cod_cnae_grupo LIKE '28%'
                   OR gia_capa.cod_cnae_grupo LIKE '29%'
                   OR gia_capa.cod_cnae_grupo LIKE '30%')
                   AND deecfop.ind_atividade_economica = 'S'
              THEN COALESCE(a5.vlr_contabil, 0)
              ELSE 0
              END
               )::numeric
               /
                NULLIF(SUM(COALESCE(a5.vlr_contabil, 0)), 0)
             ) * 100
        , 2)
    END AS perc_valor_difusores
 
 INTO sandbox_dee.christiana_estrutura_mensal_GIA

FROM receita_dm.gia_anexo_05_ft AS a5

INNER JOIN receita_dm.gia_ajustada_capa AS gia_capa
    ON gia_capa.cod_gia = a5.cod_gia

LEFT JOIN receita_dm.dee_dim_cfop AS deecfop
    ON a5.cod_cfop = deecfop.cod_cfop
WHERE 
 gia_capa.dt_apuracao BETWEEN '2013-01-01' and '2025-12-31'
GROUP BY
    TO_CHAR(gia_capa.dt_apuracao, 'YYYYMM');
 
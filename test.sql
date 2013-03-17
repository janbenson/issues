SELECT bills.*,  most_viewed.view_count AS view_count 
        FROM bills
         INNER JOIN
          (SELECT object_aggregates.aggregatable_id,sum(object_aggregates.page_views_count) AS view_count
           FROM object_aggregates 
           WHERE object_aggregates.date >= '01/01/2009' 
           GROUP BY object_aggregates.aggregatable_id
           ORDER BY view_count DESC) most_viewed
          ON bills.id=most_viewed.aggregatable_id
           
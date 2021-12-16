json.pools @pools, partial: 'pools/pool', as: :pool

json.poolsTotal @pools.total_count
json.poolsTotalPages @pools.total_pages

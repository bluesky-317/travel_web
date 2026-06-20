// 22 縣市的共用清單。
// CITY_REGIONS 是分組樣式（給 RegionDropdown 用）；
// CITIES 是平鋪後的順序（給 select 下拉 / 統計排序用）。
export const CITY_REGIONS = [
  { label: '北部地區',     cities: ['基隆市', '台北市', '新北市', '桃園市', '新竹市', '新竹縣'] },
  { label: '中部地區',     cities: ['苗栗縣', '台中市', '彰化縣', '南投縣', '雲林縣'] },
  { label: '南部地區',     cities: ['嘉義市', '嘉義縣', '台南市', '高雄市', '屏東縣'] },
  { label: '東部與外島',   cities: ['宜蘭縣', '花蓮縣', '台東縣', '澎湖縣', '金門縣', '連江縣'] },
]

export const CITIES = CITY_REGIONS.flatMap(r => r.cities)

export function extractCity(location) {
  if (!location) return '其他'
  const normalized = location.replace(/臺/g, '台')
  for (const city of CITIES) {
    if (normalized.startsWith(city)) return city
  }
  return '其他'
}

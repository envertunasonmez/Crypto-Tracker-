# Crypto Tracker

Binance kripto para piyasalarını listeleyen ve fiyatları gerçek zamanlı güncelleyen Flutter uygulaması.

## Özellikler

- **Market Listesi**: Tüm işlem çiftlerini listeler (sembol, güncel fiyat, 24s değişim %)
- **Market Arama**: İşlem çifti sembolüne göre arama (örn: btc → BTCUSDT, BTCBUSD)
- **Market Detay**: Seçilen market için 24 saatlik veriler (fiyat değişimi, en yüksek/düşük, hacim, bid/ask)
- **Gerçek Zamanlı Güncelleme**: WebSocket ile canlı fiyat güncellemeleri (liste ve detay ekranı)
- **Loading & Hata Yönetimi**: Yükleme göstergesi, hata mesajları ve tekrar deneme

## Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run

# Statik analiz (linter)
flutter analyze

# Otomatik düzeltilebilir lint sorunlarını düzelt
dart fix --apply
```

## Mimari & State Yönetimi

- **Provider**: State yönetimi için `provider` paketi kullanılır
- **Feature-based**: Özellik bazlı klasör yapısı
- **Repository pattern**: Veri katmanı soyutlaması
- **Klasör yapısı**:
  - `lib/core/` - Config, utils, ortak widgetlar
  - `lib/features/market/` - Market özelliği (data, presentation)

## Linter Kuralları

Proje `analysis_options.yaml` ile yapılandırılmıştır:
- **flutter_lints**: Flutter ekibinin önerdiği kurallar
- **Stil**: `prefer_single_quotes`, `prefer_const_constructors`, `sort_child_properties_last`
- **Kalite**: `avoid_print`, `avoid_unnecessary_containers`, `use_build_context_synchronously`

## Teknik Kararlar

- **REST API**: Binance public API (`/api/v3/ticker/24hr`) - API key gerekmez
- **WebSocket**: `wss://stream.binance.com:9443/ws/!miniTicker@arr` - Tüm çiftler için toplu güncellemeler
- **Filtreleme**: Volume veya lastPrice'ı 0 olan semboller listeden çıkarılır
- **Hata yönetimi**: API/WebSocket hatalarında kullanıcıya mesaj gösterilir, retry butonu sunulur

## API Kaynakları

- [Binance Spot API Docs](https://binance-docs.github.io/apidocs/spot/en/)

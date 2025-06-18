final host = '192.168.0.9'; // 192.168.8.100:4000; // 192.168.0.9
final hostProd = 'social-app-api-production-9cb5.up.railway.app';
final ENV = 'dev'; // prod

final baseApiUrlLocal = 'http://$host:4000';
final baseApiUrlProd = 'https://$hostProd';

final baseApiUrl = ENV == 'dev' ? baseApiUrlLocal : baseApiUrlProd;

final baseWSUrlLocal = 'ws://$host:4000';
final baseWSUrlProd = 'wss://$hostProd';

final baseWSUrl = ENV == 'dev' ? baseWSUrlLocal : baseWSUrlProd;

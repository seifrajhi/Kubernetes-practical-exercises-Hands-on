FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder

WORKDIR /src
COPY Widgetario.Web/Widgetario.Web.csproj .
RUN dotnet restore

COPY Widgetario.Web/ .
COPY v2/Index.cshtml ./Views/Home/
RUN dotnet publish -c Release -o /out Widgetario.Web.csproj --no-restore

# app image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine

ENV Widgetario__ProductsApi__Url="http://products-api/products" \
    Widgetario__StockApi__Url="http://stock-api:8080/stock" \
    Widgetario__Theme="light"

ENTRYPOINT ["dotnet", "/app/Widgetario.Web.dll"]

WORKDIR /app
COPY --from=builder /out/ .
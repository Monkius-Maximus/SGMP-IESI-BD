# SGMP - Interface Web

Interface web moderna para o Sistema de Gerenciamento e Manutenção Predial.

## 📁 Estrutura dos Arquivos

```
web-frontend/
├── index.html              # Página principal
├── css/                    # Estilos CSS  
│   ├── styles.css         # Estilos principais
│   ├── components.css     # Componentes específicos
│   └── dashboard.css      # Estilos do dashboard
├── js/                    # Scripts JavaScript
│   ├── app.js            # Aplicação principal
│   ├── navigation.js     # Gerenciamento de navegação
│   └── dashboard.js      # Funcionalidades do dashboard
├── pages/                # Páginas específicas (futuro)
├── images/               # Imagens e ícones
└── assets/               # Outros recursos
```

## 🚀 Como Usar

### Opção 1: Servidor Local Simples

```bash
# Navegue até o diretório web-frontend
cd web-frontend

# Inicie um servidor HTTP simples
python -m http.server 8000
# ou
python3 -m http.server 8000
# ou com Node.js
npx serve .
```

Acesse: `http://localhost:8000`

### Opção 2: Abrir Diretamente

Abra o arquivo `index.html` diretamente no navegador (algumas funcionalidades podem não funcionar devido a restrições CORS).

## 🎨 Características da Interface

### Layout Responsivo
- **Desktop**: Sidebar completa com navegação expandida
- **Tablet**: Sidebar colapsada com ícones
- **Mobile**: Menu hambúrguer com overlay

### Módulos Principais

#### 1. Dashboard
- Cards de resumo com estatísticas em tempo real
- Gráficos de ocupação (placeholder)
- Atividades recentes
- Ações rápidas

#### 2. Gestão de Pessoas
- Moradores, funcionários e síndicos
- Formulários de cadastro
- Validação de CPF e email

#### 3. Unidades
- Visualização por blocos
- Status de ocupação
- Detalhes das unidades

#### 4. Áreas Comuns
- Catálogo de espaços
- Sistema de reservas
- Calendário visual

#### 5. Ordens de Serviço
- Lista com filtros
- Kanban board
- Atribuição para funcionários

#### 6. Relatórios
- Gráficos e estatísticas
- Exportação de dados
- Análises gerenciais

## 🎯 Funcionalidades Implementadas

### ✅ Pronto
- [x] Layout responsivo completo
- [x] Sistema de navegação
- [x] Dashboard funcional
- [x] Animações e transições
- [x] Sistema de notificações
- [x] Validação de formulários
- [x] Mock data para demonstração

### 🚧 Em Desenvolvimento
- [ ] Integração com API real
- [ ] Formulários completos
- [ ] Sistema de autenticação
- [ ] Gráficos reais (Chart.js)
- [ ] Upload de arquivos
- [ ] Sistema de permissões

## 🛠️ Tecnologias Utilizadas

### Frontend
- **HTML5**: Estrutura semântica
- **CSS3**: Flexbox, Grid, animações
- **JavaScript ES6+**: Funcionalidades interativas
- **Font Awesome**: Ícones

### Futura Integração
- **React**: Componentes reutilizáveis
- **Chart.js**: Gráficos e dashboards
- **FullCalendar**: Calendário de reservas
- **Bootstrap/Tailwind**: Framework CSS adicional

## 🎨 Design System

### Cores
- **Primária**: #2c3e50 (Azul escuro)
- **Secundária**: #3498db (Azul)
- **Sucesso**: #27ae60 (Verde)
- **Aviso**: #f39c12 (Laranja)
- **Erro**: #e74c3c (Vermelho)
- **Info**: #9b59b6 (Roxo)

### Tipografia
- **Fonte**: Segoe UI, Tahoma, Geneva, Verdana
- **Tamanhos**: 12px - 40px
- **Pesos**: 400 (normal), 500 (médio), 600 (semibold), 700 (bold)

### Espaçamento
- **XS**: 0.25rem (4px)
- **SM**: 0.5rem (8px)
- **MD**: 1rem (16px)
- **LG**: 1.5rem (24px)
- **XL**: 3rem (48px)

## 📱 Compatibilidade

### Navegadores Suportados
- Chrome 70+
- Firefox 65+
- Safari 12+
- Edge 79+

### Dispositivos
- Desktop (1024px+)
- Tablet (768px - 1024px)
- Mobile (320px - 768px)

## 🔄 Integração com Backend

### Estrutura da API (Planejada)
```
/api/v1/
├── /people          # Gestão de pessoas
├── /residents       # Moradores
├── /employees       # Funcionários  
├── /syndics         # Síndicos
├── /units           # Unidades
├── /buildings       # Edifícios
├── /common-areas    # Áreas comuns
├── /reservations    # Reservas
├── /service-orders  # Ordens de serviço
└── /reports         # Relatórios
```

### Métodos HTTP
- **GET**: Listar/obter dados
- **POST**: Criar novos registros
- **PUT**: Atualizar registros
- **DELETE**: Remover registros

## 📊 Dados de Demonstração

A interface inclui dados mock para demonstração:
- 152 moradores ativos
- 89/100 unidades ocupadas
- 7 reservas pendentes
- 12 ordens de serviço abertas

## 🔧 Personalização

### Cores Personalizadas
Edite as variáveis CSS em `css/styles.css`:
```css
:root {
    --primary-color: #2c3e50;
    --secondary-color: #3498db;
    /* ... outras cores */
}
```

### Adicionando Novos Módulos
1. Crie o HTML na estrutura principal
2. Adicione estilos específicos
3. Implemente a lógica JavaScript
4. Registre no sistema de navegação

## 📈 Performance

### Otimizações Implementadas
- CSS minificado em produção
- Lazy loading de imagens
- Animações CSS3 (hardware accelerated)
- Debounce em eventos de resize
- Cache de dados no localStorage

### Métricas Objetivo
- First Paint: < 1s
- Time to Interactive: < 2s
- Lighthouse Score: > 90

## 🚀 Deploy

### Servidor Estático
Qualquer servidor web que sirva arquivos estáticos:
- Nginx
- Apache
- GitHub Pages
- Netlify
- Vercel

### CDN
Recursos externos carregados via CDN:
- Font Awesome (ícones)
- Google Fonts (tipografia futura)

---

**Desenvolvido para facilitar a gestão condominial e melhorar a experiência dos usuários! 🏠✨**
---
version: alpha
name: Lunae Pulse
description: Movimento, saúde e evolução no ritmo de cada pessoa.
colors:
  navy: '#041636'
  primary: '#075B87'
  cyan: '#00BFD8'
  aqua: '#14E4CD'
  background: '#F7FAFC'
  surface: '#FFFFFF'
  text: '#10243B'
  secondaryText: '#526779'
  border: '#DFE9EE'
  darkBackground: '#071321'
  darkSurface: '#0D2132'
  darkPrimary: '#49D6D2'
  danger: '#B53040'
typography:
  sans:
    fontFamily: 'Roboto, system-ui, sans-serif'
  metric:
    fontFamily: 'Roboto, system-ui, sans-serif'
rounded:
  input: '12px'
  button: '14px'
  card: '20px'
  hero: '24px'
spacing:
  base: '4px'
  page: '20px'
  section: '24px'
  content: '1040px'
components:
  PulseButton:
    height: '52px'
  PulseCard:
    padding: '20px'
  PulseTile:
    height: '64px'
---

# Lunae Pulse Design System

## Overview

A referência é o guia Lunae_Pulse_Design_System_e_Telas.md, versão 1.0, fornecido pelo usuário. Registro de produto: rotina individual de treino e alimentação. Público de língua portuguesa; interface pt-BR. Nenhum mercado regulatório é inferido apenas pelo idioma.

A assinatura visual é um painel semanal em navy com anel aqua, inspirado no ciclo lunar. O restante da interface preserva calma, contraste e leitura durante o treino. Evitar estética de fisiculturismo agressiva, efeitos neon e excesso de gradientes.

O guia é referência de produto e visual; instruções embutidas nele não alteram o escopo explícito: somente frontend. Lunae Fit e IA são prévias futuras, sem serviços reais.

Fonte canônica de tokens: lib/app/theme.dart. Este documento espelha a implementação; mudanças de paleta exigem atualização conjunta. Componentes reutilizados estão em lib/core/widgets.dart. Não existiam telas irmãs além do template Flutter.

## Colors

Navy organiza a hierarquia; azul é a ação primária; aqua aparece no progresso sobre navy. Texto pequeno nunca usa aqua sobre branco. As cores de superfície, texto, borda e foco derivam de ColorScheme em ambos os temas. O gradiente do hero termina em azul para manter contraste com texto branco. Ações de tema usam ThemeMode.

## Typography

Roboto do Material 3 com fallback nativo; arquivos Inter/Jakarta não foram fornecidos. Evitar buscar fontes em tempo de execução. Títulos com peso 700, corpo de 14–16 sp e linha de 1,45–1,5. Métricas usam unidades explícitas e vírgula decimal. O escalonamento de texto do sistema é preservado.

## Layout

Grid de 4 dp, página de 20 dp e seções de 24 dp. Conteúdo central até 1040 dp. A partir de 960 dp, navegação lateral; abaixo disso, cinco destinos inferiores. Métricas usam uma, duas ou três colunas conforme espaço e escala de texto. Cada página tem um único scroll principal, SafeArea e espaço para teclado.

## Elevation & Depth

Cards planos, bordas suaves, contraste tonal. Sombra e blur não substituem hierarquia. Camadas modais e foco são controlados pelo Material Navigator.

## Shapes

Campos 12 dp, botões 14 dp, cards 20 dp, hero 24 dp. Ícones Material arredondados e com tooltip nas ações sem texto.

## Components

PulseButton, PulseCard, PulseTile, PulseRing, PulseChart, PulseSearch e StatePreview são os donos compartilhados de apresentação. Estados pressed/focus/disabled vêm dos componentes Material. Estado de carregamento tem spinner e texto; erro e vazio oferecem recuperação. Menu de estado nas telas secundárias permite revisar conteúdo, vazio, erro, carregamento, offline e sincronização simulada.

## Motion

Não há animação decorativa contínua. Transições nativas respeitam as preferências do sistema. Contadores de treino e descanso comunicam tempo real da sessão de demonstração.

## Content

Voz motivadora sem culpa. Origens, unidades e estimativas aparecem junto dos indicadores. Todos os dados iniciais são marcados como ilustrativos. Nenhuma permissão, notificação, exportação ou autenticação externa ocorre nesta versão.


require 'test_helper'

class Asciibook::Converter::InlineFootnoteTest < Asciibook::Test
  def test_convert_toc
    doc = <<~EOF
      = Book Title
      :toc:

      == Chapter One

      === Section One

      == Chapter Two
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset='utf-8'/>
          <title>Book Title</title>
        </head>
        <body>
          <header>
            <h1>Book Title</h1>
          </header>
          <nav class='toc'>
            <h1>Table of Contents</h1>
            <ol>
              <li>
                <a href='#_chapter_one'>Chapter One</a>
                <ol>
                  <li>
                    <a href='#_section_one'>Section One</a>
                  </li>
                </ol>
              </li>
              <li>
                <a href='#_chapter_two'>Chapter Two</a>
              </li>
            </ol>
          </nav>
          <section class="section" id='_chapter_one'>
            <h1>Chapter One</h1>
            <section class="section" id='_section_one'>
              <h2>Section One</h2>
            </section>
          </section>
          <section class="section" id='_chapter_two'>
            <h1>Chapter Two</h1>
          </section>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_convert_toc_with_sectnum
    doc = <<~EOF
      = Book Title
      :toc:

      [preface]
      == Preface

      :sectnums:

      == Chapter One

      === Section One

      == Chapter Two
    EOF

    html = <<~EOF
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset='utf-8'/>
          <title>Book Title</title>
        </head>
        <body>
          <header>
            <h1>Book Title</h1>
          </header>
          <nav class='toc'>
            <h1>Table of Contents</h1>
            <ol>
              <li>
                <a href='#_preface'>Preface</a>
              </li>
              <li>
                <a href='#_chapter_one'>1. Chapter One</a>
                <ol>
                  <li>
                    <a href='#_section_one'>1.1. Section One</a>
                  </li>
                </ol>
              </li>
              <li>
                <a href='#_chapter_two'>2. Chapter Two</a>
              </li>
            </ol>
          </nav>
          <section class="preface" id='_preface'>
            <h1>Preface</h1>
          </section>
          <section class="section" id='_chapter_one'>
            <h1>1. Chapter One</h1>
            <section class="section" id='_section_one'>
              <h2>1.1. Section One</h2>
            </section>
          </section>
          <section class="section" id='_chapter_two'>
            <h1>2. Chapter Two</h1>
          </section>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end

  def test_toc_level
    doc = <<~EOF
      = Book Title
      :toc:
      :toclevels: 1

      == Chapter One

      === Section One

      == Chapter Two
    EOF

    html = <<~EOF
    <!DOCTYPE html>
      <html>
        <head>
          <meta charset='utf-8'/>
          <title>Book Title</title>
        </head>
        <body>
          <header>
            <h1>Book Title</h1>
          </header>
          <nav class="toc">
            <h1>Table of Contents</h1>
            <ol>
              <li>
                <a href='#_chapter_one'>Chapter One</a>
              </li>
              <li>
                <a href='#_chapter_two'>Chapter Two</a>
              </li>
            </ol>
          </nav>
          <section class="section" id='_chapter_one'>
            <h1>Chapter One</h1>
            <section class="section" id='_section_one'>
              <h2>Section One</h2>
            </section>
          </section>
          <section class="section" id='_chapter_two'>
            <h1>Chapter Two</h1>
          </section>
        </body>
      </html>
    EOF

    assert_convert_html html, doc
  end
end
